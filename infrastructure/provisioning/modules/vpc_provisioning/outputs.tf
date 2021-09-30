output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "security_groups" {
  value = [aws_vpc.vpc.default_security_group_id]
}

output "default_sec_group_id" {
  value = aws_vpc.vpc.default_security_group_id
}
output "vpc_private_subnet_ids" {
  value = aws_subnet.private_subnet.*.id
}

output "vpc_public_subnet_ids" {
  value = aws_subnet.public_subnet.*.id
}