```bash
kubectl config use-context bare
kubectl get nodes                                   # NotReady
kubectl describe node cka-bare-worker | grep -i network
#   NetworkReady=false ... cni plugin not initialized

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.3/manifests/calico.yaml
kubectl -n kube-system rollout status ds/calico-node
kubectl get nodes -w                                # Ready after ~1 min
kubectl -n net-check get pod probe -o wide          # Running, IP 192.168.x.x

ssh cka-bare-worker                                 # here: ./cka ssh cka-bare-worker
ls /etc/cni/net.d/                                  # 10-calico.conflist  calico-kubeconfig
ls /opt/cni/bin/                                    # the plugin binaries Calico's install-cni container copied in
exit
echo 10-calico.conflist > {{ANSWERS}}/cni-config.txt
```
**What to know:** the kubelet/containerd read the CNI config from `/etc/cni/net.d/` and run the binaries in `/opt/cni/bin/`;
until a config exists the node stays NotReady and carries the `node.kubernetes.io/not-ready` taint, so pods stay Pending.
Use `kubectl create` (or `kubectl apply --server-side`): Calico's CRDs are too large for the annotation that client-side `apply` writes.
Calico's default pool (`CALICO_IPV4POOL_CIDR`, 192.168.0.0/16) must match the cluster's pod CIDR — it does here, otherwise edit it before applying.
