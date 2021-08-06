################################################################################################
####                              Fetches the Public Subnet                          ###########
################################################################################################

data "aws_subnet_ids" "all_subnets" {
  vpc_id = "${var.vpc_id}"
    tags = {
    Network = "Public-*"
    Name = "Public"
  }
}

data "aws_subnet" "subnet_id" {
  count = "${length(data.aws_subnet_ids.all_subnets.ids)}"
  id    = "${tolist(data.aws_subnet_ids.all_subnets.ids)[count.index]}"
}

output "subnet_cidr_blocks" {
  value = "${data.aws_subnet.subnet_id.*.id}"
}

data "aws_subnet" "example" {
  for_each = data.aws_subnet_ids.all_subnets.ids
  id       = each.value
}

output "subnet_cidr_blockss" {
  value = [for s in data.aws_subnet.example : s.id]
}

###############################################################################################
####    Creates Security Group for the MediaWiki instance with ingress and egress   ###########
###############################################################################################
resource "aws_security_group" "security_group" {
  name        = lower("${var.application_name}-${var.application_environment}-rds-sg-test")
  description = lower("${var.application_name}-${var.application_environment}-rds")
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags= {
    Name = "mediawiki-sg1"
    Project = "mediawiki"
  }
}

###############################################################################################
######             Fetches the Latest CENTOS AMI from Amazon Market Place           ###########
###############################################################################################

data "aws_ami" "centos" {
owners      = ["aws-marketplace"]
most_recent = true

  filter {
      name   = "name"
      values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
      name   = "architecture"
      values = ["x86_64"]
  }

  filter {
      name   = "root-device-type"
      values = ["ebs"]
  }
}



resource "aws_lb" "appln" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.security_group.id}"]
  subnets            = "${data.aws_subnet.subnet_id.*.id}"
  tags = {
    Project = "mediawiki"
  }
}

resource "aws_lb_listener" "blue" {
  load_balancer_arn = "${aws_lb.appln.arn}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    forward {
      target_group {
        arn    = "${aws_lb_target_group.blue.arn}"
        weight = "${local.traffic_dict[var.deployment].blue}"
      }

      target_group {
        arn    = "${aws_lb_target_group.green.arn}"
        weight =  "${local.traffic_dict[var.deployment].green}"
      }

      stickiness {
        enabled  = true
        duration = 600
      }
     }
    }
}