```bash
kubectl config use-context main
kubectl -n payments create serviceaccount release-bot
kubectl -n payments create role release-bot --verb=get,list,watch,create,update,patch --resource=deployments.apps \
  --dry-run=client -o yaml > role.yaml
vim role.yaml        # add a second rule
```
```yaml
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list"]
```
```bash
kubectl apply -f role.yaml
kubectl -n payments create rolebinding release-bot --role=release-bot --serviceaccount=payments:release-bot
kubectl create clusterrole node-reader --verb=get,list --resource=nodes
kubectl create clusterrolebinding release-bot-node-reader --clusterrole=node-reader --serviceaccount=payments:release-bot

SA=system:serviceaccount:payments:release-bot
kubectl auth can-i get pods --subresource=log --as $SA -n payments   # yes
kubectl auth can-i delete deployments --as $SA -n payments            # no
kubectl auth can-i list nodes --as $SA                                # yes
```
**Notes:** logs are the `pods/log` subresource — `get pods` alone doesn't allow `kubectl logs`. Nodes are cluster-scoped,
so they need a ClusterRole **and** a ClusterRoleBinding (a RoleBinding to a ClusterRole only grants namespaced resources
inside that one namespace). Deployments are in the `apps` group, pods in the core group `""`.
