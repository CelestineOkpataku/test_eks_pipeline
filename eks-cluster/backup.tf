data "aws_iam_policy_document" "eks_disaster_recovery_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "eks_backup_role" {
  name               = "eks_backup_cluster_role"
  assume_role_policy = data.aws_iam_policy_document.eks_disaster_recovery_role.json
}

resource "aws_iam_role_policy_attachment" "eks_backup_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.eks_backup_role.name
}

resource "aws_backup_vault" "eks_backup_vault" {
  name = "eks_backup_vault"
}

resource "aws_backup_plan" "eks_cluster_backup_plan" {
  name = "eks-cluster-backup-plan-${module.eks_blueprints.eks_cluster_id}"

  rule {
    rule_name         = "eks-cluster-backup-rule"
    target_vault_name = aws_backup_vault.eks_backup_vault.name
    schedule          = "cron(0 12 * * ? *)"

    lifecycle {
      delete_after = 14
    }
  }

}

# Create a backup selection for the EKS cluster
resource "aws_backup_selection" "eks_cluster_backup_selection" {
  name         = "eks-cluster-backup-selection"
  iam_role_arn = aws_iam_role.eks_backup_role.arn
  plan_id      = aws_backup_plan.eks_cluster_backup_plan.id
  selection_tag {
    type  = "STRINGEQUALS"
    key   = "kubernetes.io/cluster/okpataku-c"
    value = "owned"
  }
}
