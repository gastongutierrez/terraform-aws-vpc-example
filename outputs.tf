output "ssh_private_key_pem" {
    value = tls_private_key.ssh.private_key_pem
    sensitive = true
}

output "ssh_public_key_pem" {
    value = tls_private_key.ssh.public_key_pem
    sensitive = true
}

output "prod_public_instance_private_ip" {
    value = aws_instance.prod-public-instance.private_ip
}

output "prod_private_instance_private_ip" {
    value = aws_instance.prod-private-instance.private_ip
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
