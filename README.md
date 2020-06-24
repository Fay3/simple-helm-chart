# simple-helm-chart
Simple Helm Chart with Hello World html Page with Terraforming EKS cluster

## Prerequisites
* Minikube [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)
* Helm [Helm](https://helm.sh/docs/intro/install/)
* AWScli [AWScli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* Terraform [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)

ensure minikube is running and your current kubeclt context is pointing at your local minikube

## Commands to get started
1. Enable minikube ingress
  ```bash
  minikube addons enable ingress
  ```

2. In the root of the git repo run:
  ```bash
  helm upgrade simple-helm-chart --install helm/
  ```

this should now have deployed "simple-helm-chart" on your local minikube

2. to view "Hello World" html page via minikube run the following:
  ```bash
  minikube service simple-helm-chart --url
  ```

this should give back a url containing the address and port which you will be able to visit displaying a hello world html page

or you can do the following to access locally

3. grab the ip address from the Address column by running
  ```bash
  kubectl get ingress simple-helm-chart
  ```
4. add the following line to the end of `/etc/hosts` file
  ```
  <ip_address_from_step_3> simple-helm-chart.local
  ```
Note replace <ip_address_from_step_3> with the IP address you grabbed from step 3

5. now visit `http://simple-helm-chart.local` on your local browser

this should display a hello world html page

## Terraform

1. terrform apply from root of repo
  ```bash
  cd terraform && terraform apply
  ```

AWS Infrastructure
* VPC
* Internet Gateway
* 3x NatGateways
* 3x Elastic IP
* 6x Route Tables
* 1x Private subnet zone a
* 1x Private subnet zone b
* 1x Private subnet zone c
* 1x Public subnet zone a
* 1x Public subnet zone b
* 1x Public subnet zone c
* 2x Security Groups
* 1x Autoscaling group as a bastion
* 3x IAM roles and policies
* 1x EKS Cluster
* 1X EKS Node Group

Kubernetes
* 1x Namespace
* 1x alb-ingress-controller


## EKS

2. update local kubconfig to use eks context
  ```bash
  aws eks update-kubeconfig --name simple-helm-chart
  ```

## Roadmap
* Terraform IaC for spot instances and k8s config for autoscaler
* K8s files for Rbac
* Pipeline for Build
