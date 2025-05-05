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

source functions.sh

# Function to start a service and wait until it becomes active
start_and_wait_for_service() {
  local service_name="$1"
  local max_attempts="${2:-10}"  # Default to 10 attempts if not specified
  local sleep_seconds="${3:-2}"  # Default to 2 seconds between attempts

  log "Starting ${service_name} service..."
  sudo systemctl enable "${service_name}"
  sudo systemctl start "${service_name}"

  log "Waiting for ${service_name} to become active..."
  for attempt in $(seq 1 "$max_attempts"); do
    if systemctl is-active --quiet "${service_name}"; then
      log "${service_name} is active and running."
      return 0
    else
      log "${service_name} not ready yet. Retrying (${attempt}/${max_attempts})..."
      sleep "${sleep_seconds}"
    fi
  done

  log "ERROR: ${service_name} failed to start after ${max_attempts} attempts."
  exit 1
}

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