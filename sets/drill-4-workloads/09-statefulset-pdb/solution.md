```bash
kubectl config use-context main
kubectl -n kv create service clusterip kv --clusterip=None --tcp=6379:6379 --dry-run=client -o yaml > svc.yaml
#   change the selector to app: kv (create service sets app: kv already, since the name is kv), then apply
kubectl -n kv create deploy kv --image=redis:7-alpine --replicas=3 --port=6379 --dry-run=client -o yaml > sts.yaml
#   kind: StatefulSet, add spec.serviceName: kv, remove strategy/status
kubectl apply -f svc.yaml -f sts.yaml
kubectl -n kv create pdb kv-pdb --selector=app=kv --min-available=2
kubectl -n kv get pdb kv-pdb                 # ALLOWED DISRUPTIONS 1
echo kv-1.kv.kv.svc.cluster.local > {{ANSWERS}}/kv-replica.txt
kubectl -n kv exec kv-0 -- redis-cli -h kv-1.kv ping
```
Docs: *StatefulSets → Stable Network ID* and *Specifying a Disruption Budget for your Application*.

- StatefulSet pods are numbered from 0, so the second replica is `kv-1`. Its DNS name is `<pod>.<serviceName>.<namespace>.svc.cluster.local`.
- That name only exists if `spec.serviceName` points to a **headless** Service (`clusterIP: None`) that selects the pods.
- A PDB only protects against voluntary evictions (drain, the eviction API). It doesn't stop `kubectl delete pod` or a node crash.
  `minAvailable: 2` and `maxUnavailable: 1` behave the same here.
