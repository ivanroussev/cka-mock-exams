`kubectl create role` accepts subresources in `--resource` (`deployments.apps/scale`), but one rule per command —
so generate, then add the second rule:
```bash
kubectl config use-context alt
kubectl -n release create role deployment-scaler --verb=get,list,watch --resource=deployments.apps \
  --dry-run=client -o yaml > role.yaml
vim role.yaml
```
```yaml
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments/scale"]
  verbs: ["get", "update", "patch"]
```
```bash
kubectl apply -f role.yaml
kubectl -n release create rolebinding deploy-bot-scaler --role=deployment-scaler --serviceaccount=release:deploy-bot
SA=system:serviceaccount:release:deploy-bot
kubectl auth can-i patch deployments.apps --subresource=scale --as $SA -n release   # yes
kubectl auth can-i patch deployments.apps --as $SA -n release                       # no
kubectl auth can-i --list --as $SA -n release
```
**Least privilege:** `kubectl scale` only needs the `scale` subresource. Granting `update` on `deployments` would also let
the bot change images, env and commands. `--serviceaccount` takes `<namespace>:<name>`.
