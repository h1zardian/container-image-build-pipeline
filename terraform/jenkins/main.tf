provider "aws" {
  region = "ap-south-1" # change to your AWS region
}

resource "aws_instance" "jenkins" {
  ami           = "ami-0f5ee92e2d63afc18" # replace with the correct AMI ID for Jenkins
  instance_type = "t2.medium"              # adjust as necessary

  key_name = "cicd-pipeline-ec2-key" # replace with your key pair name

  vpc_security_group_ids = [aws_security_group.jenkins.id]

  associate_public_ip_address = true

  tags = {
    Name = "jenkins-server"
  }
}

resource "aws_security_group" "jenkins" {
  name        = "jenkins-sg"
  description = "Allow inbound traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
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
