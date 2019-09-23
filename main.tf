provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
  #provider.aws: version = "~> 2.15"
}

data "aws_ami" "latestnginxserver" {
  most_recent      = true
  owners           = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["amazon_linux-aws/nodejs_46_nginx*"]
  }
}


resource "aws_instance" "appsvr" {
  ami                     = "${data.aws_ami.latestnginxserver.id}"
  instance_type           = "t2.micro"
  key_name                = "${var.ssh_key_name}"
  vpc_security_group_ids  = ["${aws_security_group.appsvr-sg.id}"]
  count                   = var.appservercount

  tags = {
    Name = "disposableappsvr${count.index}"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = "${var.ssh_key_private)}"
    host        = self.public_ip
  }

}

resource "aws_security_group" "appsvr-sg" {
  name   = "tfas_sg"
  vpc_id = "vpc-109e4678"
  description = "used as part of terraform build and configuration"

  # enable SSH access in order to perform post build provisioning
  # TODO: fix the anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # access to the node.js server
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # access to the juice shop
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}