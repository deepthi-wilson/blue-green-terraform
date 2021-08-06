
###############################################################################################
######       Creates the MediaWiki Instance with given instance type and keypair    ###########
###############################################################################################


resource "aws_instance" "blue" {
  count = "${var.blue_count}"
  ami = "${data.aws_ami.centos.id}"
  instance_type = "${var.ec2_instance_type}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.security_group.id}"]
  subnet_id = "${data.aws_subnet.subnet_id[0].id}"

  tags={
    Name = "mediawiki-instance1-blue-${count.index}"
    Project = "mediawiki"
  }
}


resource "aws_lb_target_group" "blue" {
  name     = "tf-blue-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 5
    interval = 10
  }
}

resource "aws_lb_target_group_attachment" "blue" {
  count = length(aws_instance.blue)
  target_group_arn = aws_lb_target_group.blue.arn
  target_id        = aws_instance.blue[count.index].id
  port             = 80
}
