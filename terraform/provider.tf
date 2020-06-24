provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = aws_eks_cluster.shc_eks.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.shc_eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
  load_config_file       = false
}
