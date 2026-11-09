The nodes of cluster `bare` are **NotReady** and pod `probe` in namespace `net-check` is stuck in Pending.
The cluster was built without a network plugin. Its pod CIDR is `192.168.0.0/16`.

1. Install the Calico CNI, **version v3.32.3**, from its manifest:
   `https://raw.githubusercontent.com/projectcalico/calico/v3.32.3/manifests/calico.yaml`
2. Make sure both nodes become Ready and pod `probe` runs with an IP address from the pod CIDR.
3. Write the file name of the CNI configuration that Calico installs on node `cka-bare-worker` (only the file name,
   not the path) to `{{ANSWERS}}/cni-config.txt`.
