#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <kubernetes-version> (e.g. 1.23.0) <endpoint DNS Name/IP>" >&2
  exit 1
fi
K8S_VERSION_RAW="$1"
K8S_ENDPOINT="$2"

# Logging helper
log() {
  echo ">>> [$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"
}

log "Setting up kernel modules and sysctl for Kubernetes networking..."
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system

log "Initializing the Kubernetes control plane node..."
sudo kubeadm init \
  --control-plane-endpoint ${K8S_ENDPOINT} \
  --upload-certs \
  --pod-network-cidr 192.168.0.0/16 \
  --kubernetes-version ${K8S_VERSION_RAW}

# Step 3: Set up kubeconfig for the user
log "Setting up kubeconfig for user..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Step 4: Install Network Plugin (Calico)
log "Installing network plugin..."
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

sudo mkdir $HOME/.kube/
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

log "Control plane setup completed."