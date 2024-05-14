# Terraform Configuration for AWS EKS Cluster and Add-ons

This Terraform configuration sets up an AWS EKS cluster along with various add-ons and supporting infrastructure to create a resilient and scalable Kubernetes environment.


## Important Note

Before deploying this Terraform configuration in a production environment, it's essential to review and update certain configurations such as the backend, permissions etc. to suit your specific use case.I left mine so that you know where to make the change.

## Project Structure

The project is structured to have multiple files named after the resource or service being created. Each resource or service has its own dedicated Terraform configuration file, facilitating organization and maintainability.

### Why Not .tfvars Files?

While Terraform best practices often advocate for using .tfvars files for storing variable values, in this project, values are directly embedded within the configuration files themselves. This decision was made to prioritize readability and ease of understanding for users who may not be familiar with Terraform or the project structure. However, in a production environment, it's recommended to use .tfvars files for better management of sensitive information and to follow security best practices.


### File Structure Example:


## Prerequisites

Before you begin, ensure you have:

- An AWS account
- Terraform installed locally
- AWS CLI configured with appropriate access credentials
- Change Backend and other configuration 


## Configuration Details

### Backend Configuration

The Terraform backend is configured to use an S3 bucket for storing the state file and DynamoDB for state locking. This ensures secure and consistent state management across multiple users and environments.

### Kubernetes Add-ons

The configuration includes several Kubernetes add-ons managed via Helm, such as:

- **AWS EBS CSI Driver:** Allows for dynamic provisioning and management of Amazon EBS volumes for persistent storage.
- **AWS EFS CSI Driver:** Enables Kubernetes pods to use Amazon EFS file systems as persistent volumes.
- **AWS Load Balancer Controller:** Automatically configures and manages AWS Load Balancers for Kubernetes services.
- **Metrics Server:** Collects resource metrics from Kubernetes nodes and pods.
- **Cert Manager:** Manages TLS certificates for Kubernetes applications, ensuring secure communication.
- **Karpenter:** Autoscaling for Kubernetes clusters based on resource utilization and pod scheduling.
- **Vault:** Integrates HashiCorp Vault for managing secrets and sensitive data in Kubernetes.
- **Kubecost:** Enables cost analysis and allocation for Kubernetes clusters.
- **Nginx Ingress:** Provides external access to Kubernetes services through Nginx ingress controller.
- **Prometheus:** Sets up monitoring and alerting for Kubernetes clusters.

### IAM Roles for Backup

IAM roles and policies are created to enable AWS Backup service to perform backup and restore operations on the EKS cluster, ensuring data protection and disaster recovery readiness.

### Backup Resources

AWS Backup Vault, Plan, and Selection resources are provisioned to automate the backup process for the EKS cluster, including lifecycle management and tagging for efficient organization and retrieval of backups.

### Kubernetes Resources

Various Kubernetes resources are provisioned, including namespaces, deployments, and configuration maps, to support add-ons like Kubecost for cost analysis, Nginx Ingress for external access, and Prometheus for monitoring and alerting.

### VPC Configuration

A custom VPC is created with multiple availability zones, public and private subnets, NAT gateways, and network ACLs to provide networking isolation and high availability for the EKS cluster and associated resources.

## Usage

1. Clone this repository.
2. Ensure AWS credentials are configured.
3. Initialize Terraform: `terraform init`.
4. Review and apply the changes: `terraform apply`.
5. Confirm changes and apply.

## Variables

Various variables can be customized to tailor the configuration to specific requirements, such as VPC CIDR block, default security group settings, and add-on options.

## Outputs

The output includes the ID of the created VPC for reference and integration with other resources or configurations.

## Author

- Celestine Okpataku

