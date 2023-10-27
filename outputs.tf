/*
output "public_ip" {
  description = "Public IP of instance (or EIP)"
  value       = concat(aws_eip.default[*].public_ip, aws_instance.default[*].public_ip, [""])[0]
}
*/
output "private_ip" {
  description = "Private IP of instance"
  value       = one(aws_instance.default[*].private_ip)
}


output "id" {
  description = " ID of the instance"
  value       = one(aws_instance.default[*].id)
}

output "arn" {
  description = "ARN of the instance"
  value       = one(aws_instance.default[*].arn)
}

output "name" {
  description = "Instance name"
  value       = var.instance_name
}


output "security_group_ids" {
  description = "IDs on the AWS Security Groups associated with the instance"
  value = aws_instance.default.vpc_security_group_ids
  
}

output "role" {
  description = "Name of AWS IAM Role associated with the instance"
  value       = aws_iam_role.iam.name
}

output "role_arn" {
  description = "ARN of AWS IAM Role associated with the instance"
  value       = aws_iam_role.iam[*].arn
}
/*
output "alarm" {
  description = "CloudWatch Alarm ID"
  value       = one(aws_cloudwatch_metric_alarm.default[*].id)
}

*/
output "ebs_ids" {
  description = "IDs of EBSs"
  value       = aws_ebs_volume.default[*].id
}

output "security_group_id" {
  value       = aws_security_group.security_groups[*].id
  description = "EC2 instance Security Group ID"
}

output "security_group_arn" {
  value       = aws_security_group.security_groups[*].arn
  description = "EC2 instance Security Group ARN"
}

output "security_group_name" {
  value       = aws_security_group.security_groups[*].name
  description = "EC2 instance Security Group name"
}