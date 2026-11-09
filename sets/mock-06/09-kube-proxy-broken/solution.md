Endpoints are fine, so the Service → pod translation on the nodes is broken. That's **kube-proxy**'s job; "old Services still work"
is the hint: their iptables rules were written before kube-proxy died, new ones never get rules.

```bash
kubectl -n api get endpointslices -l kubernetes.io/service-name=quotes     # 2 endpoints, port 9000 — OK
kubectl -n kube-system get pods -l k8s-app=kube-proxy -o wide              # CrashLoopBackOff
kubectl -n kube-system logs -l k8s-app=kube-proxy --tail=5
#   … invalid configuration: … mode: Unsupported value: "iptabels"
kubectl -n kube-system edit cm kube-proxy                                  # config.conf → mode: "iptables"
kubectl -n kube-system rollout restart ds kube-proxy                       # pods only read the ConfigMap at start
#   (if a node is down the rollout can stall on it — then delete the pod on the node you need directly)
ssh cka-alt-control-plane "iptables-save | grep quotes"                    # KUBE-SVC rules appear
```
**Pitfalls:** editing the ConfigMap changes nothing until the kube-proxy pods restart. kube-proxy is a DaemonSet (not a static pod),
so its config lives in the `kube-proxy` ConfigMap, not under `/etc/kubernetes/manifests`.
