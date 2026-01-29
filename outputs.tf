output "instance_id" {
  value = aws_instance.ec2.id
}

output "public_ip" {
  value = aws_instance.ec2.public_ip
}

output "ssh_command" {
  value = var.enable_ssh ? "ssh -i terra-key.pem ec2-user@${aws_instance.ec2.public_ip}" : "SSH disabled. Use SSM."
}

output "ssm_command" {
  value = "aws ssm start-session --target ${aws_instance.ec2.id}"
}

