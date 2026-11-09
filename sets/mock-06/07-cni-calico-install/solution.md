```bash
kubectl config use-context bare
kubectl get nodes                                       # NotReady: "network plugin is not ready: cni config uninitialized"
kubectl -n kube-system get cm kubeadm-config -o yaml | grep podSubnet     # 192.168.0.0/16
grep -n -A1 CALICO_IPV4POOL_CIDR {{FILES}}/calico.yaml    # value: "10.10.0.0/16"  ← wrong
sed -i 's#10.10.0.0/16#192.168.0.0/16#' {{FILES}}/calico.yaml      # (or comment the variable out: Calico then uses its default 192.168.0.0/16)
kubectl create -f {{FILES}}/calico.yaml                 # the manifest is large: create (or apply --server-side), not plain apply
kubectl -n kube-system get pods -l k8s-app=calico-node -w
kubectl get nodes                                       # Ready
kubectl get ippools -o wide                             # 192.168.0.0/16

kubectl run probe-b --image=nginx:1.27-alpine
kubectl get pod probe-b -o wide                         # IP 192.168.x.y
kubectl run t --rm -it --image=busybox:1.37 --restart=Never -- wget -qO- http://<that-ip>
```
**Pitfalls:** a pool outside the cluster's pod CIDR "works" at first but breaks routing and kube-proxy's cluster-CIDR assumptions —
always match the CNI's CIDR to `--pod-network-cidr`. Plain `kubectl apply` of calico.yaml can fail with
"metadata.annotations: Too long" on the big CRDs; use `kubectl create` or `apply --server-side`.
