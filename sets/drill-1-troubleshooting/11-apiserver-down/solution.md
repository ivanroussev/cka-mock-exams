`kubectl` can't help when the API server itself is down — go to the node and ask the container runtime.
```bash
kubectl get nodes                    # The connection to the server … was refused
ssh cka-bare-control-plane
crictl ps -a | grep kube-apiserver   # Exited, attempt count rising
crictl logs <container-id> 2>&1 | tail
#  … dial tcp 127.0.0.1:2397: connect: connection refused   (etcd listens on 2379)
ls /var/log/pods/ ; tail /var/log/pods/kube-system_kube-apiserver-*/kube-apiserver/*.log   # same logs, if crictl shows nothing
grep listen-client-urls /etc/kubernetes/manifests/etcd.yaml   # where etcd really listens
vim /etc/kubernetes/manifests/kube-apiserver.yaml   # --etcd-servers=https://127.0.0.1:2379
# kubelet notices the change and recreates the static pod (give it up to a minute)
watch crictl ps                       # then: kubectl get pods -n kube-system
echo --etcd-servers > {{ANSWERS}}/apiserver-flag.txt
```
**Order of tools when the API is down:** `crictl ps -a` → `crictl logs` → `/var/log/pods/…` → `journalctl -u kubelet`
(if the pod isn't even created, e.g. YAML syntax error in the manifest). Never keep a backup copy *inside*
`/etc/kubernetes/manifests/` — kubelet runs every file there.
