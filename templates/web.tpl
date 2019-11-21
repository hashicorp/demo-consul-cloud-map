#!/bin/bash

apt-get update && apt-get install -y unzip

# Get internal IP
LOCAL_IPV4=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

cd /tmp

# Fetch Fake service
wget https://github.com/nicholasjackson/fake-service/releases/download/v0.7.8/fake-service-linux -O /usr/local/bin/fake-service
chmod +x /usr/local/bin/fake-service

%{ if consul_cluster_addr != "" }
# Fetch Envoy
wget https://github.com/nicholasjackson/cloud-pong/releases/download/v0.3.0/envoy -O /usr/local/bin/envoy
chmod +x /usr/local/bin/envoy

# Fetch Consul
wget https://releases.hashicorp.com/consul/1.6.0/consul_1.6.0_linux_amd64.zip -O ./consul.zip
unzip ./consul.zip
mv ./consul /usr/local/bin

# Create the consul config
mkdir -p /etc/consul/config

cat << EOF > /etc/consul/config.hcl
data_dir = "/tmp/"
log_level = "DEBUG"
datacenter = "${dc}"
bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
ports {
  grpc = 8502
}
connect {
  enabled = true
}
enable_central_service_config = true
advertise_addr = "$${LOCAL_IPV4}"
retry_join = ["${consul_cluster_addr}"]
EOF

# Create config and register service
cat << EOF > /etc/consul/config/web.json
{
  "service": {
    "name": "web",
    "id":"web",
    "port": 9090,
    "checks": [
      {
       "id": "web",
       "name": "Web on port 9090",
       "http": "http://localhost:9090/health",
       "tls_skip_verify": false,
       "method": "GET",
       "interval": "10s",
       "timeout": "1s"
      }
    ],
    "connect": { 
      "sidecar_service": {
        "port": 20000,
        "proxy": {%{ if use_proxy }
          "upstreams": [
            {
              "destination_name": "api",
              "local_bind_address": "127.0.0.1",
              "local_bind_port": 9092
            }
          ]
        %{ endif }}
      }
    }  
  }
}
EOF

# Setup systemd Consul Agent
cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description=Consul Server
After=syslog.target network.target
[Service]
ExecStart=/usr/local/bin/consul agent -config-file=/etc/consul/config.hcl -config-dir=/etc/consul/config
ExecStop=/bin/sleep 5
Restart=always
[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/consul.service

# Setup systemd Envoy Sidecar
cat << EOF > /etc/systemd/system/consul-envoy.service
[Unit]
Description=Consul Envoy
After=syslog.target network.target
[Service]
ExecStart=/usr/local/bin/consul connect envoy -sidecar-for web
ExecStop=/bin/sleep 5
Restart=always
[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/consul-envoy.service

systemctl daemon-reload

systemctl start consul.service
systemctl start consul-envoy.service
%{ endif }

# Setup DNS
cat << EOF > /etc/systemd/resolved.conf
[Resolve]
DNS=127.0.0.1
#FallbackDNS=
Domains=~consul
#LLMNR=no
#MulticastDNS=no
#DNSSEC=no
#Cache=yes
#DNSStubListener=yes
EOF

systemctl restart systemd-resolved
iptables -t nat -A OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
iptables -t nat -A OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600

# Setup systemd Web service
cat << EOF > /etc/systemd/system/web.service
[Unit]
Description=Web
After=syslog.target network.target
[Service]
Environment="MESSAGE=Web ${dc}"
Environment="NAME=Web (${dc})"
Environment=UPSTREAM_URIS=%{ if use_proxy }http://localhost:9092%{ else }http://${api_endpoint}:9090%{ endif }
Environment=TRACING_ZIPKIN=http://${shared_services_private_ip}:9411
ExecStart=/usr/local/bin/fake-service
ExecStop=/bin/sleep 5
Restart=always
[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/web.service

systemctl daemon-reload
systemctl start web.service
