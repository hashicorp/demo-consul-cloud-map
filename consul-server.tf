resource "aws_iam_role" "consul_server" {
  name = "consul_server"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "consul_server" {
  name = "consul_policy"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Sid" : "AllowInstancePermissions",
         "Effect": "Allow",
         "Action": [
            "servicediscovery:RegisterInstance",
            "servicediscovery:DeregisterInstance",
            "servicediscovery:DiscoverInstances",
            "servicediscovery:CreateService",
            "servicediscovery:Get*",
            "servicediscovery:List*",
            "route53:GetHostedZone",
            "route53:ListHostedZonesByName",
            "route53:ChangeResourceRecordSets",
            "route53:CreateHealthCheck",
            "route53:GetHealthCheck",
            "route53:DeleteHealthCheck",
            "route53:UpdateHealthCheck"
         ],
         "Resource": "*"
      }
   ]
}
EOF
}

resource "aws_iam_policy_attachment" "consul_server" {
  name       = "consul-server"
  roles      = [aws_iam_role.consul_server.name]
  policy_arn = aws_iam_policy.consul_server.arn
}

resource "aws_iam_instance_profile" "consul_server" {
  name = "consul_server"
  role = aws_iam_role.consul_server.name
}

resource "aws_eip" "consul_server_onprem" {
  vpc        = true
  depends_on = [aws_internet_gateway.default]
}

resource "aws_eip_association" "consul_server_onprem" {
  instance_id   = aws_instance.consul_server_onprem.id
  allocation_id = aws_eip.consul_server_onprem.id
}

resource "aws_instance" "consul_server_onprem" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_vpc.default.default_security_group_id]
  subnet_id              = aws_subnet.default[0].id

  user_data = templatefile("${path.module}/templates/consul-server.tpl", {
    dc_public_ip       = aws_eip.consul_server_onprem.public_ip,
    other_dc_public_ip = aws_eip.consul_server_aws.public_ip,
    namespace_id       = aws_service_discovery_private_dns_namespace.example.id,
    aws_region         = data.aws_region.current.name,
    dc                 = "onprem"
  })

  iam_instance_profile = aws_iam_instance_profile.consul_server.name

  tags = {
    Name     = "Consul"
    Location = "OnPrem"
  }
}

resource "aws_eip" "consul_server_aws" {
  vpc        = true
  depends_on = [aws_internet_gateway.default]
}

resource "aws_eip_association" "consul_server_aws" {
  instance_id   = aws_instance.consul_server_aws.id
  allocation_id = aws_eip.consul_server_aws.id
}

resource "aws_instance" "consul_server_aws" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_vpc.default.default_security_group_id]
  subnet_id              = aws_subnet.default[1].id

  user_data = templatefile("${path.module}/templates/consul-server.tpl", {
    dc_public_ip       = aws_eip.consul_server_aws.public_ip,
    other_dc_public_ip = aws_eip.consul_server_onprem.public_ip,
    namespace_id       = "",
    aws_region         = data.aws_region.current.name,
    dc                 = "aws"
  })

  iam_instance_profile = aws_iam_instance_profile.consul_server.name

  tags = {
    Name     = "Consul"
    Location = "AWS"
  }
}