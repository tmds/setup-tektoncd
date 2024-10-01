#!/usr/bin/env bash
#
# Deploys a Container Registry instance, waits for the deployment reach running status.
#

shopt -s inherit_errexit
set -eu -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

phase "Deploying a Container Registry on '${REGISTRY_NAMESPACE}' namespace"

cat <<EOS |kubectl apply -o yaml -f -
---
apiVersion: v1
kind: Namespace
metadata:
  name: ${REGISTRY_NAMESPACE}

---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: registry
  namespace: ${REGISTRY_NAMESPACE}
  name: registry
spec:
  replicas: 1
  selector:
    matchLabels:
      app: registry
  template:
    metadata:
      labels:
        app: registry
    spec:
      containers:
        - image: registry:2
          name: registry
          imagePullPolicy: IfNotPresent
          env:
            - name: REGISTRY_STORAGE_DELETE_ENABLED
              value: "true"
          ports:
            - containerPort: 5000
          resources:
            requests:
              cpu: 100m
              memory: 128M
            limits:
              cpu: 100m
              memory: 128M

---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: registry
  namespace: ${REGISTRY_NAMESPACE}
  name: registry
spec:
  type: NodePort
  ports:
    - port: 32222
      nodePort: 32222
      protocol: TCP
      targetPort: 5000
  selector:
    app: registry
EOS

# phase "Adding local registry to containerd config"
# REGISTRY_DIR="/etc/containerd/certs.d/registry.${REGISTRY_NAMESPACE}.svc.cluster.local:32222"
# for node in $(kind get nodes); do
#   docker exec "${node}" mkdir -p "${REGISTRY_DIR}"
#   cat <<EOF | docker exec -i "${node}" cp /dev/stdin "${REGISTRY_DIR}/hosts.toml"
# [host."http://localhost:32222"]
# EOF
# done


phase "Waiting for Registry rollout"
rollout_status "${REGISTRY_NAMESPACE}" "registry"