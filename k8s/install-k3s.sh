#!/bin/bash

# Variables
KUBECONFIG_PATH="~/.kube/config"
CLUSTER_SERVER="https://localhost:6443"  # Replace with your cluster server address
JOIN_TOKEN="owko0t.gvof7excom7pffp0"  # Obtain from the existing cluster
CALICO_CNI_URL="https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml"
CONTAINER_NAME="k3s-node"
DOCKER_IMAGE="custom-k3s-inline"
CONTAINER_MEMORY="8g"
CONTAINER_CPUS="1"

# Create k3s container
docker run -d --name $CONTAINER_NAME \
  --cpus $CONTAINER_CPUS \
  --memory $CONTAINER_MEMORY \
  -e K3S_URL=$CLUSTER_SERVER \
  -e K3S_TOKEN=$JOIN_TOKEN \
  --network host \
  -p 16443:16443 \
  -p 11250:11250 \
  -p 18251:18251 \
  -p 18252:18252 \
  $DOCKER_IMAGE server --cluster-cidr=192.168.0.0/16 -it

# Apply Calico networking (within the cluster)
#kubectl --kubeconfig=$KUBECONFIG_PATH apply -f $CALICO_CNI_URL

echo "K3s node is running in Docker container and joined the cluster."

