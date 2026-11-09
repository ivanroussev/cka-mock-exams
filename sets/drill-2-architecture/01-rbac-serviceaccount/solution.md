```bash
kubectl config use-context main
kubectl -n ci-pipeline create serviceaccount deployer
# Different verbs per resource → generate one rule, then add the second one in the file
kubectl -n ci-pipeline create role deploy-manager \
  --verb=get,list,watch,create,update,patch --resource=deployments --dry-run=client -o yaml > role.yaml
```
Add the pods rule to `role.yaml`:
```yaml
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get","list","watch","create","update","patch"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get","list"]
```
```bash
kubectl apply -f role.yaml
kubectl -n ci-pipeline create rolebinding deployer-binding --role=deploy-manager --serviceaccount=ci-pipeline:deployer

# Verify what is allowed AND what is denied
kubectl auth can-i create deployments -n ci-pipeline --as system:serviceaccount:ci-pipeline:deployer   # yes
kubectl auth can-i delete deployments -n ci-pipeline --as system:serviceaccount:ci-pipeline:deployer   # no
kubectl auth can-i --list -n ci-pipeline --as system:serviceaccount:ci-pipeline:deployer
```
**Pitfalls:** `kubectl create role` gives every `--verb` on every `--resource`, so different verbs per resource need a second rule.
Deployments are in API group `apps`, pods in the core group `""`. With `--as`, a ServiceAccount is `system:serviceaccount:<ns>:<name>`.
