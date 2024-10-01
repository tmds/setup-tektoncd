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
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry.registry.svc.cluster.local:32222"]
    endpoint = ["http://registry.registry.svc.cluster.local:32222"]
  [plugins."io.containerd.grpc.v1.cri".registry.configs."registry.registry.svc.cluster.local:32222".tls]
    insecure_skip_verify = true
EOF
kind export kubeconfig

source .env

./install-registry.sh
./install-tekton.sh