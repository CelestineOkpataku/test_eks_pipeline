
module "eks_blueprints" {
    source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.25.0"

    cluster_name = "okpataku-c"
    cluster_version = "1.27"

    enable_irsa = true

    vpc_id = module.vpc.vpc_id

    private_subnet_ids = module.vpc.private_subnets

    managed_node_groups = {
        role = {
            capacity_type = "ON_DEMAND"
            node_group_name = "general"
            instance_types = ["c5.xlarge"]
            desired_size = "4"
            max_size = "6"
            min_size = "3"

        }
    }

}


