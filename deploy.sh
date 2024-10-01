#!/usr/bin/env bash
#
# Setting up a new KinD instance, and right after, rolling out the Container Registry and Tekton
# Pipelines. The instnace will be available as the current kubeconfig context.
#

shopt -s inherit_errexit
set -xeu -o pipefail

kind delete cluster
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry]
    config_path = "/etc/containerd/certs.d"
EOF
kind export kubeconfig

source .env

./install-registry.sh
./install-tekton.sh