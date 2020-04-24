# VPC
region          = "eu-west-1"
az_count        = "2"
cidr_block      = "10.0.0.0/16"
cluster_name    = "simple-helm-chart"
ssh_key_pem     = "eks_bastion_key"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
