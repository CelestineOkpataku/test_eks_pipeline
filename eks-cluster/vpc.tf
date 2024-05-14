
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
    tags = local.tags
}


resource "aws_route" "nat_gateway" {
  count          = length(module.vpc.public_route_table_ids)
  route_table_id = module.vpc.public_route_table_ids[count.index]
  destination_cidr_block = "196.182.32.48/32"
  nat_gateway_id         = module.vpc.natgw_ids[count.index]
}

resource "aws_route" "internet_gateway" {
  count          = length(module.vpc.public_route_table_ids)
  route_table_id = module.vpc.public_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc.igw_id
}