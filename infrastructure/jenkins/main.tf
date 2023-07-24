provider "aws" {
  region = "ap-south-1" # change to your AWS region
}

resource "aws_instance" "jenkins" {
  ami           = "ami-0f5ee92e2d63afc18" # replace with the correct AMI ID for Jenkins
  instance_type = "t2.medium"              # adjust as necessary

  key_name = "cicd-pipeline-ec2-key" # replace with your key pair name

  vpc_security_group_ids = [aws_security_group.jenkins.id]

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "tfstate-bucket-20230723" # replace with a unique bucket name
}

resource "aws_s3_bucket_ownership_controls" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tfstate" {
  depends_on = [aws_s3_bucket_ownership_controls.tfstate]

  bucket = aws_s3_bucket.tfstate.id
  acl    = "private"
}
