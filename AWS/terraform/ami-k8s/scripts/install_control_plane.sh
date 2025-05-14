#!/usr/bin/env bash
set -euo pipefail

# Argument validation
K8S_VERSION_RAW="${1:-}"
if [[ -z "$K8S_VERSION_RAW" ]]; then
  echo "ERROR: Kubernetes version argument is required."
  echo "Usage: $0 <kubernetes-version> (e.g. 1.23.0)"
  exit 1
fi

PKG_VER="${K8S_VERSION_RAW}-00"
MAIN_VER="${K8S_VERSION_RAW%.*}"

source "$(dirname "$0")/functions.sh"

log "Starting Kubernetes control plane setup (requested version: ${K8S_VERSION_RAW}, pkg version: ${PKG_VER})"

# Step 1: Install containerd and Kubernetes components
log "Installing containerd..."
sudo yum install -y containerd

log "Installing kubelet, kubeadm, kubectl..."
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v${MAIN_VER}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v${MAIN_VER}/rpm/repodata/repomd.xml.key
EOF
sudo yum install -y kubelet-"${K8S_VERSION_RAW}" kubeadm-"${K8S_VERSION_RAW}" kubectl-"${K8S_VERSION_RAW}" iproute-tc

log "Disabling swap..."
sudo swapoff -a
sudo sed -ri '/\sswap\s/s/^/#/' /etc/fstab

start_and_wait_for_service containerd.service 10 1
start_and_wait_for_service kubelet.service 10 1

# Step 2: Initialize the Kubernetes control plane node

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
sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version ${K8S_VERSION_RAW}

# Step 3: Set up kubeconfig for the user
log "Setting up kubeconfig for user..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Step 4: Install Network Plugin (Calico)
log "Installing network plugin..."
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

log "Control plane setup completed."
