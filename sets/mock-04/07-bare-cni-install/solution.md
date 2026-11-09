```bash
kubectl config use-context bare
kubectl get nodes                                       # NotReady
kubectl describe node cka-bare-worker | grep -A6 Conditions
#   Ready False … container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized
kubectl get node cka-bare-worker -o jsonpath='{.status.conditions[?(@.type=="Ready")].message}' > {{ANSWERS}}/bare-notready.txt
grep -n -A1 CALICO_IPV4POOL_CIDR {{FILES}}/calico.yaml # commented out → Calico uses 192.168.0.0/16 by default, which matches
kubectl apply -f {{FILES}}/calico.yaml
kubectl -n kube-system get pods -w                      # calico-node 1/1 on both nodes, then coredns Running
ssh cka-bare-worker ls /etc/cni/net.d/                  # here: ./cka ssh cka-bare-worker
echo 10-calico.conflist > {{ANSWERS}}/bare-cni-file.txt
```
**How it fits together:** the kubelet asks the container runtime (CRI) for network status; containerd reports ready only once a CNI config
exists in `/etc/cni/net.d/`. Calico's `install-cni` init container writes that file and the plugin binaries into `/opt/cni/bin/`.
If your cluster's pod CIDR differs from Calico's default, set `CALICO_IPV4POOL_CIDR` in the manifest before applying it.
