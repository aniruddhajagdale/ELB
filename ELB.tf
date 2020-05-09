provider "aws" {
  profile = "default"
  region  = "${var.region}"
}

resource "aws_instance" "ec2" {
  ami                  = "${var.ami}"
  instance_type        = "t2.micro"
  key_name             = "EC2 Key"
  iam_instance_profile = "s3-admin-access"
  tags = {
    Name = "WebServer"
  }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:\\Users\\ajagdale\\Documents\\EC2 Key")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install httpd -y",
      "sudo aws s3 cp s3://s3-aniruddha/index.html /var/www/html/",
      "sudo service httpd start",
      "sudo chkconfig httpd on"
    ]
  }
}

resource "aws_elb" "c-elb" {
  name               = "Classic-ELB"
  availability_zones = "${data.aws_availability_zones.az-name.names}"
  security_groups    = ["${data.aws_security_groups.sg.ids[0]}"]
  access_logs {
    bucket   = "${var.elb-log-bucket}"
    interval = 5
    enabled  = true
  }
  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }
  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 3
    target              = "HTTP:80/index.html"
    interval            = 30
    timeout             = 20
  }
  cross_zone_load_balancing = false
  instances                 = ["${aws_instance.ec2.id}"]

}

output "dns-url" {
  value = "${aws_elb.c-elb.dns_name}"
}

