resource "aws_ecr_repository" "ecr_helios" {
  name = "${var.cluster_name}-helm-repo"

  image_scanning_configuration {
    scan_on_push = true
  }
}
