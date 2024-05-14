
module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.0.0"

    name = "okpataku-vpc"
    cidr = "10.0.0.0/16"
   

    azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
    private_subnets = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"] 
    public_subnets = ["10.0.96.0/19", "10.0.128.0/19", "10.0.160.0/19"]

    enable_dns_hostnames = true
    enable_dns_support = true

    enable_nat_gateway = true
    single_nat_gateway = true
    one_nat_gateway_per_az = false
   
    public_subnet_tags = {
        "kubernetes.io/role/elb" = 1
        "kubernetes.io/cluster/okpataku-c" = "owned"
    }

    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = 1
        "kubernetes.io/cluster/okpataku-c" = "owned"
    }
}


resource "aws_route" "nat_gateway" {
  for_each = module.vpc.public_subnets
  route_table_id         = aws_route_table_association.public[each.key].route_table_id
  destination_cidr_block = "196.182.32.48/32"
  nat_gateway_id         = module.vpc.natgw_ids
}

resource "aws_route" "internet_gateway" {
  for_each = module.vpc.public_subnets
  route_table_id         = aws_route_table_association.public[each.key].route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc.igw_id
}

/*
resource "aws_network_acl" "eks_nacl" {
  vpc_id = module.vpc.vpc_id

 
 egress {
    protocol   = "-1"  # All protocols
    rule_no    = 200
    action     = "deny"  # Deny all egress traffic by default
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"  # All protocols
    rule_no    = 100
    action     = "allow"  # Allow all inbound traffic from the specific CIDR block
    cidr_block = "196.182.32.48/32"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "main"
  }
}

# Associate public subnet with NACL resource

resource "aws_network_acl_association" "public_subnet_association" {
  count = local.create_vpc ? length(module.vpc.public_subnets) : 0
  network_acl_id = aws_network_acl.eks_nacl.id
  subnet_id      = module.vpc.public_subnets[count.index]
}

# Associate private subnet with Nacl resource
resource "aws_network_acl_association" "private_subnet_association" {
  count = local.create_vpc ? length(module.vpc.private_subnets) : 0
  network_acl_id = aws_network_acl.eks_nacl.id
  subnet_id      = module.vpc.private_subnets[count.index]
}

resource "aws_security_group" "default_override" {
  name        = "override-default"
  description = "Override default security group with custom rules"
  vpc_id      = module.vpc.vpc_id

  // Only allow traffic from CIDR block 196.182.32.48/32
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["196.182.32.48/32"]
  }

  // Optionally, you can also explicitly deny all other traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Add any other tags or configurations as needed
}

// Associate the overridden default security group with the VPC's default security group
resource "aws_default_security_group" "this" {
  count = local.create_vpc && var.manage_default_security_group ? 1 : 0

  vpc_id = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = var.default_security_group_ingress
    content {
      // Override the ingress rules with the custom security group's ingress rules
      self             = lookup(ingress.value, "self", null)
      cidr_blocks      = aws_security_group.default_override.id != "" ? [] : compact(split(",", lookup(ingress.value, "cidr_blocks", "")))
      ipv6_cidr_blocks = compact(split(",", lookup(ingress.value, "ipv6_cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(ingress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(ingress.value, "security_groups", "")))
      description      = lookup(ingress.value, "description", null)
      from_port        = lookup(ingress.value, "from_port", 0)
      to_port          = lookup(ingress.value, "to_port", 0)
      protocol         = lookup(ingress.value, "protocol", "-1")
    }
  }

  dynamic "egress" {
    for_each = var.default_security_group_egress
    content {
      self             = lookup(egress.value, "self", null)
      cidr_blocks      = compact(split(",", lookup(egress.value, "cidr_blocks", "")))
      ipv6_cidr_blocks = compact(split(",", lookup(egress.value, "ipv6_cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(egress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(egress.value, "security_groups", "")))
      description      = lookup(egress.value, "description", null)
      from_port        = lookup(egress.value, "from_port", 0)
      to_port          = lookup(egress.value, "to_port", 0)
      protocol         = lookup(egress.value, "protocol", "-1")
    }
  }


}


variable "manage_default_security_group" {
  description = "Should be true to adopt and manage default security group"
  type        = bool
  default     = true
}

variable "default_security_group_name" {
  description = "Name to be used on the default security group"
  type        = string
  default     = null
}

variable "default_security_group_ingress" {
  description = "List of maps of ingress rules to set on the default security group"
  type        = list(map(string))
  default     = []
}

variable "default_security_group_egress" {
  description = "List of maps of egress rules to set on the default security group"
  type        = list(map(string))
  default     = []
}

variable "default_security_group_tags" {
  description = "Additional tags for the default security group"
  type        = map(string)
  default     = {}
}

locals {
  create_vpc = true  # or false, depending on your condition
}
*/