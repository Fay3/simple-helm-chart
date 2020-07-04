resource "aws_s3_bucket" "helm_repo_bucket" {
  bucket = "${var.cluster_name}-helm-repo"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    "Name" = "${var.cluster_name}-helm-repo"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_object" "helm_index_yaml" {
  bucket                 = aws_s3_bucket.helm_repo_bucket.bucket
  key                    = "charts/index.yaml"
  source                 = "../helm/index.yaml"
  server_side_encryption = "AES256"
}



