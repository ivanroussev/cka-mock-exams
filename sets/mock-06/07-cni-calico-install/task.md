Cluster `bare` was built with kubeadm but **no network plugin**, so its nodes are NotReady.

1. Install **Calico** using the manifest `{{FILES}}/calico.yaml`. The cluster's pod network CIDR is `192.168.0.0/16`;
   check the manifest before you apply it — Calico's IP pool must match the cluster's pod CIDR.
2. When both nodes are Ready, run a pod `probe-b` (image `nginx:1.27-alpine`) in namespace `default` and confirm that another pod
   can reach it on its pod IP.
