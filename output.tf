output "aws_lb-public" {
   value = aws_lb.lb-desafiopublico.dns_name
}
output "aws_lb-interno" {
   value = aws_lb.lb-desafiopriv.dns_name
}
output "instance_ips" {
  value = aws_instance.bastion.public_ip
}
output "database_endpoint" {
   value = aws_db_instance.default.endpoint
}