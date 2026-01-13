output "server_public_ip" {
  description = "The static public IP of the server"
  value       = aws_eip.lb.public_ip
}

output "ssh_connection_string" {
  description = "Command to connect to the server"
  value       = "ssh ubuntu@${aws_eip.lb.public_ip}"
}