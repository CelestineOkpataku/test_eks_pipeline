terraform {
  backend "s3" {
    bucket         = "celestine-okpataku-remote-backend"
    key            = "okpataku/comcast-assessment/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "dynamodb-state-locking"

  }
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}
data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}



    provider "helm" {
        kubernetes {
            host = module.eks_blueprints.eks_cluster_endpoint
            cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

            exec {
                api_version = "client.authentication.k8s.io/v1beta1"
                command = "aws"
                args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
            }
        }
    }

