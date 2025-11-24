output "instance-public-ip"{
    value = aws_instance.myinstance.public_ip
}
output "instance-private-ip" {
  value = aws_instance.myinstance.private_ip
}