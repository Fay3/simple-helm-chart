variable "tag_name" {
  description = "Tag Name of services"
  type        = string
}

variable "region" {
  description = "The aws region"
  type        = string
}

variable "cidr_block" {
  description = "The cidr block for vpc"
  type        = string
}

variable "cluster_name" {
  description = "The eks cluster name"
  type        = string
}
