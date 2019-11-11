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

data "template_file" "consul_server" {
  template = file("${path.module}/templates/consul-server.tpl")

  vars = {
    namespace_id = aws_service_discovery_private_dns_namespace.example.id
    aws_region = "us-east-1"
  }
}

resource "aws_instance" "consul_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_vpc.default.default_security_group_id]
  subnet_id     = aws_subnet.default[0].id
  associate_public_ip_address = true

  user_data = data.template_file.consul_server.rendered

  iam_instance_profile = aws_iam_instance_profile.consul_server.name

  tags = {
    Name = "Consul_Server"
  }
}
