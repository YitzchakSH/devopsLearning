#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <kubernetes-version> (e.g. 1.23.0) <number of control planes> <number of workers>" >&2
  exit 1
fi

K8S_VERSION="$1"
CONTROL_INSTANCES="$2"
WORKER_INSTANCES="$3"

AMI=$(aws ec2 describe-images \
  --owners self \
  --filters "Name=name,Values=ami-k8s-v$K8S_VERSION" \
  --query 'Images[*].ImageId' \
  --output text | tr -d '[:space:]')

if [ -z "${AMI}" ]; then
    SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
    cd "$SCRIPT_DIR/../../../ami-k8s/"
    packer build -var "k8s_version=$K8S_VERSION" "$(dirname "$0")/../ami-k8s.pkr.hcl" >&2
fi

AMI = $(aws ec2 describe-images \
  --owners self \
  --filters "Name=name,Values=ami-k8s-v$K8S_VERSION" \
  --query 'Images[*].ImageId' \
  --output text | tr -d '[:space:]')
echo "{\"result\": \"${AMI}\"}"