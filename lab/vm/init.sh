#!/bin/bash
# kubeadm init on this node, then install the flannel CNI.
# Usage: init.sh <control-plane endpoint host> [--upload-certs]
set -eux
EP="$1"; shift
kubeadm init --control-plane-endpoint "$EP:6443" --pod-network-cidr 10.244.0.0/16 "$@"
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl wait --for=condition=Ready node --all --timeout=300s
