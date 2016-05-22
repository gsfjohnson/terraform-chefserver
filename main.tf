provider "aws" {
    region = "${var.aws_region}"
}

##
## CHEF SERVER
##

resource "aws_security_group" "chefserver" {
  name = "${var.aws_sg_name}"
  description = "Allow Chef Ports from world"
  # vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #cidr_blocks = ["${split(",", var.org_cidr_blocks)}"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.aws_sg_name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "template_file" "script" {
  template = "chef-server-install.sh"

  vars {
    "fqdn" = "${var.aws_r53_record_name}.${var.aws_r53_zone_domain}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "chefserver" {
  ami = "${var.aws_instance_ami}"
  instance_type = "${var.aws_instance_type}"
  vpc_security_group_ids = ["${split(",", aws_security_group.chefserver.id)}"]
  associate_public_ip_address = true
  ebs_optimized = false
  key_name = "${var.aws_keyname}"
  user_data = "${template_file.script.rendered}"
  availability_zone = "${var.aws_availability_zone}"

  tags {
    Name= "${var.aws_r53_record_name}"
    Owner = "${var.owner_tag}"
    Application = "${var.application_tag}"
    Environment = "${var.environment_tag}"
    Fund = "${var.fund_tag}"
    Org = "${var.org_tag}"
    ClientDepartment = "${var.clientdepartment_tag}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "chefserver" {
  zone_id = "${var.aws_r53_zone_id}"
  name = "${format("%s.%s", var.aws_r53_record_name, var.aws_r53_zone_domain)}"
  type = "A"
  ttl = "300"
  records = ["${aws_instance.chefserver.public_ip}"]
}
