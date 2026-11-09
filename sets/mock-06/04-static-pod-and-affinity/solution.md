```bash
ssh cka-main-worker
grep staticPodPath /var/lib/kubelet/config.yaml        # /etc/kubernetes/manifests
cat <<'YAML' > /etc/kubernetes/manifests/node-agent.yaml
apiVersion: v1
kind: Pod
metadata: {name: node-agent, namespace: default}
spec:
  containers:
  - name: agent
    image: busybox:1.37
    command: ["sh", "-c", "while true; do date; sleep 30; done"]
    resources:                                     # requests == limits for every resource → Guaranteed
      requests: {cpu: 50m, memory: 32Mi}
      limits:   {cpu: 50m, memory: 32Mi}
YAML
exit
kubectl get pod node-agent-cka-main-worker -o wide     # mirror pod, name gets the node name appended

kubectl label node cka-main-worker2 disk=ssd
kubectl -n edge-cache edit deploy edge-cache
#   spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution:
#     nodeSelectorTerms: [{matchExpressions: [{key: disk, operator: In, values: [ssd]}]}]
kubectl -n edge-cache get pods -o wide
```
Tip: generate the static pod YAML on your workstation with `kubectl run node-agent --image=busybox:1.37 --dry-run=client -o yaml -- sh -c '…'`.
**Pitfalls:** a static pod created with `kubectl apply` is just a normal pod — it has to be a file in the kubelet's `staticPodPath`
on that node. "Required" means `requiredDuringScheduling…`; `preferred…` would still allow other nodes.
