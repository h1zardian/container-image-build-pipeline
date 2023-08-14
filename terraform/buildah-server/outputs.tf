output "ec2_instance_public_ip" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.buildah.public_ip
}