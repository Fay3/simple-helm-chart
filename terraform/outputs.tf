locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes

CONFIGMAPAWSAUTH
}

output "config_map_aws_auth" {
  value = local.config_map_aws_auth
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.shc_eks.endpoint
}

output "eks_cluster_certificat_authority" {
  value = aws_eks_cluster.shc_eks.certificate_authority 
}
