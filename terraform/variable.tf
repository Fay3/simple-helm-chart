variable "region" {
  description = "The aws region"
  type        = string
}

variable "az_count" {
  description = "avaliability zone count"
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

variable "public_subnets" {
  description = "The cidrs for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "The cidrs for public subnets"
  type        = list(string)
}

variable "ssh_key_pem" {
  description = "The ssh key pem name used for bastion"
  type        = string
}
