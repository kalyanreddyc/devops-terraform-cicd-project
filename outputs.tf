output "sonarqube_server_ip" {
  description = "The public IP address of the SonarQube server"
  value       = aws_instance.sonarqube.public_ip
}

output "nexus_server_ip" {
  description = "The public IP address of the Nexus server"
  value       = aws_instance.nexus.public_ip
}

# output "nexus_admin_password" {
#   description = "The initial admin password for Nexus"
#   value       = aws_instance.nexus.public_ip
# }