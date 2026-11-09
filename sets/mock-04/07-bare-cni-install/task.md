Both nodes of cluster `bare` are `NotReady`, and the CoreDNS pods are `Pending`.

1. Find out why. Write the reason as the kubelet reports it in the node's `Ready` condition (the `message` field of that condition) to `{{ANSWERS}}/bare-notready.txt`.
2. Fix the cluster by installing Calico from the manifest `{{FILES}}/calico.yaml`. The cluster's pod network is `192.168.0.0/16`.
3. On node `cka-bare-worker`, find the CNI configuration file Calico installed and write its **file name** (no path) to `{{ANSWERS}}/bare-cni-file.txt`.

At the end both nodes must be `Ready` and CoreDNS must be running.
