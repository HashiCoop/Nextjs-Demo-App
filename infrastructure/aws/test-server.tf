data "hcp_packer_artifact" "base_security" {
  bucket_name  = "base-security"
  channel_name = "latest"
  platform     = "aws"
  region       = "us-east-1"
}

resource "aws_launch_template" "template" {
  name_prefix     = "nextjs-demo-app-template"
  image_id        = data.hcp_packer_artifact.base_security.external_identifier
  user_data =     base64encode(file("startup.sh"))
  instance_type   = "t3.small"

  key_name = "nextjs-demo-app"

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.public_demo.id, data.tfe_outputs.network.values.vpc.default_security_group_id]
  }

  iam_instance_profile {
    arn = "arn:aws:iam::390101570318:instance-profile/nextjs-demo-app"
  }

  tag_specifications {
    resource_type = "instance"
      tags = {
        Name = "nextjs-demo-app"
      }
  }
}

resource "aws_autoscaling_group" "autoscale" {
  name                  = "nextjs-demo-app-asg"  
  desired_capacity      = 3
  max_size              = 5
  min_size              = 1
  health_check_type     = "EC2"
  termination_policies  = ["OldestInstance"]
  vpc_zone_identifier   = [data.tfe_outputs.network.values.public_subnets[0]]

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}

resource "aws_security_group" "public_demo" {
  name_prefix = "public-demo"
  description = "Allow all traffic"
  vpc_id      = data.tfe_outputs.network.values.vpc_id

  ingress {
    description = "Full Access"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb" "test" {
  name               = "nextjs-demo-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_demo.id, data.tfe_outputs.network.values.vpc.default_security_group_id]
  subnets            = [data.tfe_outputs.network.values.public_subnets[0]]

  tags = {
    Name = "nextjs-demo-app"
  }
}

resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.example.id
  elb                    = aws_elb.example.id
}