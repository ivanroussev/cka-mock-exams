```bash
kubectl config use-context main
kubectl -n team-a create quota team-a-quota --hard=pods=3,requests.cpu=1,limits.memory=1Gi
kubectl create priorityclass team-a-high --value=100000
kubectl -n team-a create deploy worker --image=nginx:1.27-alpine --replicas=4 --dry-run=client -o yaml > worker.yaml
#   add   priorityClassName: team-a-high   under spec.template.spec, then apply
kubectl -n team-a get rs                                  # DESIRED 4, CURRENT 3
kubectl -n team-a describe rs -l app=worker | grep -i quota
kubectl -n team-a get events --field-selector reason=FailedCreate -o jsonpath='{.items[-1:].message}' > {{ANSWERS}}/quota-error.txt
```
LimitRange (there's no imperative command, so copy it from the docs, *Configure Default CPU/Memory Requests and Limits for a Namespace*):
```yaml
apiVersion: v1
kind: LimitRange
metadata: {name: container-defaults, namespace: team-a}
spec:
  limits:
  - type: Container
    defaultRequest: {cpu: 100m, memory: 64Mi}
    default: {cpu: 200m, memory: 128Mi}
```
- Once a quota covers `requests.cpu` or `limits.memory`, every new pod **must** set those values or it's rejected (`must specify ...`).
  The LimitRange fills them in, which is why it has to exist first. LimitRange and quota are only checked at admission, so pods that
  already exist are never changed.
- The 4th pod isn't Pending. It's never created at all, so `kubectl get pods` doesn't show it. The error is on the **ReplicaSet**:
  `pods "worker-…" is forbidden: exceeded quota: team-a-quota, requested: pods=1, used: pods=3, limited: pods=3`.
- `kubectl describe quota -n team-a` shows Used vs Hard.
