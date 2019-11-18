#!/bin/bash

apt-get update && apt-get install -y unzip

# Get internal IP
LOCAL_IPV4=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

cd /tmp

# Fetch Fake service
wget https://github.com/nicholasjackson/fake-service/releases/download/v0.7.8/fake-service-linux -O /usr/local/bin/fake-service
chmod +x /usr/local/bin/fake-service

# Setup systemd Web service
cat << EOF > /etc/systemd/system/web.service
[Unit]
Description=Web
After=syslog.target network.target
[Service]
Environment="MESSAGE=Web ${dc}"
Environment=NAME=Web-${dc}
Environment=UPSTREAM_URIS=http://api.example.terraform:9090
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
