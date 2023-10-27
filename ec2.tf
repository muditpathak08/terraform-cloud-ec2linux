locals {
  volume_count   		     = var.ebs_volume_count
  security_group_enabled = var.enabled && var.security_group_enabled
  root_iops              = contains(["io1", "io2", "gp3"], var.root_volume_type) ? var.root_iops : null
  ebs_iops               = contains(["io1", "io2", "gp3"], var.ebs_volume_type) ? var.ebs_iops : null
  root_throughput        = var.root_volume_type == "gp3" ? var.root_throughput : null
  ebs_throughput         = var.ebs_volume_type == "gp3" ? var.ebs_throughput : null
  root_volume_type       = var.root_volume_type
}


data "aws_iam_policy_document" "default" {
  statement {
    sid = ""
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}
resource "aws_iam_role" "iam" {
  name                 = var.iam_name
  path                 = "/"
  assume_role_policy   = data.aws_iam_policy_document.default.json
  #permissions_boundary = var.permissions_boundary_arn
  tags                 = var.tags
}
resource "aws_security_group" "security_groups" {
    
    count       = length(var.security_groups)
    name        = var.security_groups[count.index]
    description = var.security_group_description
    vpc_id      = var.vpc_id
   dynamic "ingress" {
    for_each = var.ingress_security_group_rules
    content {
    from_port                   = ingress.value.from_port
    to_port                     = ingress.value.to_port
    protocol                    = ingress.value.protocol
    cidr_blocks                 = ingress.value.cidr_blocks
    description                 = ingress.value.description
    }
    }
    dynamic "egress" {
    for_each = var.egress_security_group_rules
    content {
    from_port                   = egress.value.from_port
    to_port                     = egress.value.to_port
    protocol                    = egress.value.protocol
    cidr_blocks                 = egress.value.cidr_blocks
    description                 = egress.value.description
    }
    }
    tags        = var.tags
}
/*
resource "aws_security_group_rule" "sg-rules" {
    for_each = {for s in var.security_group_rules : s.type => s}
    type                        = each.value.type
    from_port                   = each.value.from_port
    to_port                     = each.value.to_port
    protocol                    = each.value.protocol
    cidr_blocks                 = each.value.cidr_blocks
    description                 = each.value.description
    security_group_id           = aws_security_group.security_groups[0].id
}
*/
resource "aws_instance" "default" {
  ami                                  = var.ami_id
  availability_zone                    = var.availability_zone
  instance_type                        = var.instance_type
  ebs_optimized                        = var.ebs_optimized
  disable_api_termination              = false
  associate_public_ip_address 		     = var.associate_public_ip_address
  iam_instance_profile                 = aws_iam_role.iam.name
  key_name                             = var.key_name
  subnet_id                            = var.subnet_id
  monitoring                           = var.monitoring
  vpc_security_group_ids = concat(aws_security_group.security_groups[*].id,var.security_group_ids[*])
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    iops                  = local.root_iops
    throughput            = local.root_throughput
    delete_on_termination = false
    encrypted             = true
    #kms_key_id            = var.root_block_device_kms_key_id
  }

 depends_on = [aws_security_group.security_groups, aws_iam_role.iam]
tags = merge(tomap(var.tags),{Name = "var.instance_name"})

lifecycle {
     ignore_changes = [ami]
     }

}

resource "aws_ebs_volume" "default" {
  count             = local.volume_count
  availability_zone = var.availability_zone
  size              = var.ebs_volume_size
  iops              = local.ebs_iops
  throughput        = local.ebs_throughput
  type              = var.ebs_volume_type
  tags              = var.tags
  encrypted         = var.ebs_volume_encrypted
  #kms_key_id        = var.kms_key_id
}

resource "aws_volume_attachment" "default" {
  count       = local.volume_count
  device_name = var.ebs_device_name[count.index]
  volume_id   = aws_ebs_volume.default[count.index].id
  instance_id = aws_instance.default.id
}
