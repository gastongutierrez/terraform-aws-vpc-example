output "ssh_private_key_pem" {
    value = tls_private_key.ssh.private_key_pem
    sensitive = true
}

output "ssh_public_key_pem" {
    value = tls_private_key.ssh.public_key_pem
    sensitive = true
}

output "prod_frontend_instance_private_ip_1" {
    value = aws_instance.prod-frontend-instance[0].private_ip
}

output "prod_frontend_instance_private_ip_2" {
    value = aws_instance.prod-frontend-instance[1].private_ip
}

output "prod_frontend_instance_private_ip_3" {
    value = aws_instance.prod-frontend-instance[2].private_ip
}

output "prod_backend_instance_private_ip_1" {
    value = aws_instance.prod-backend-instance[0].private_ip
}

output "prod_backend_instance_private_ip_2" {
    value = aws_instance.prod-backend-instance[1].private_ip
}

output "prod_backend_instance_private_ip_3" {
    value = aws_instance.prod-backend-instance[2].private_ip
}

output "dev_public_instance_private_ip" {
    value = aws_instance.dev-public-instance.private_ip
}

output "dev_private_instance_private_ip" {
    value = aws_instance.dev-private-instance.private_ip
}

output "mgmt_jumpserver_public_ip" {
    value = aws_instance.mgmt-jumpserver-instance.public_ip
}
