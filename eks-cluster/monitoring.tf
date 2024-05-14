# Variables
variable "prometheus_version" {
  default = "2.30.0" # Change to your desired Prometheus version
}

# CloudWatch Logs Group
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/ecs/app-logs"
  retention_in_days = 30
}

# CloudTrail S3 Bucket
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "okpataku-cloudtrail-bucket"
}

# CloudTrail S3 Bucket Policy
resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.cloudtrail_bucket.arn
      },
      {
        Sid    = "AWSCloudTrailWrite",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.cloudtrail_bucket.arn}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# Prometheus Configuration
resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name      = "prometheus-config"
    namespace = "okpataku-c"
  }
  data = {
    "monitor.yml" = file("${path.module}/monitor.yml")
  }
}

# Prometheus Deployment
resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "okpataku-c"
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "prometheus"
      }
    }

    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }
      spec {
        container {
          name  = "prometheus"
          image = "prom/prometheus:latest"
          port {
            container_port = 9090
          }
          volume_mount {
            name       = "config"
            mount_path = "/etc/prometheus"
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.prometheus_config.metadata[0].name
          }
        }
      }
    }
  }
}
