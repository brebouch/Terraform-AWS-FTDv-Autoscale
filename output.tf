#############
# Outputs
#############
# If create_fmcv is TRUE then FMCv set FMCv public IP address. If FALSE set to null
output "fmc_public_ip" {
  value = var.create_fmcv ? aws_eip.fmc-mgmt-EIP[0].public_ip : null
}

output "instance_public_key" {
  value = aws_key_pair.public_key.public_key
}

output "instance_private_cert" {
  value = tls_private_key.key_pair.private_key_pem
  sensitive = true
}
