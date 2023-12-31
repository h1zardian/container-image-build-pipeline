provider "aws" {
  region = "ap-south-1" # change to your AWS region
}

resource "aws_instance" "buildah" {
  ami           = "ami-0f5ee92e2d63afc18" # replace with the correct AMI ID for Jenkins
  instance_type = "t2.medium"              # adjust as necessary

  key_name = "cicd-pipeline-ec2-key" # replace with your key pair name

  vpc_security_group_ids = [aws_security_group.buildah.id]

  associate_public_ip_address = true

  tags = {
    Name = "buildah-server"
  }
}

resource "aws_security_group" "buildah" {
  name        = "buildah-sg"
  description = "Allow inbound traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
