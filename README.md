# simple-helm-chart
Simple Helm Chart with Hello World html Page

## Prerequisites
* Minikube [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)
* Helm [Helm](https://helm.sh/docs/intro/install/)

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
