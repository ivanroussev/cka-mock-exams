```bash
kubectl -n team-red get deploy,rs,pods                 # 0/4, no pods
kubectl -n team-red describe rs -l app=worker          # FailedCreate: … failed quota: team-red-quota: must specify limits.memory,requests.cpu,requests.memory
kubectl -n team-red describe quota team-red-quota
```
```yaml
apiVersion: v1
kind: LimitRange
metadata: {name: team-red-defaults, namespace: team-red}
spec:
  limits:
  - type: Container
    defaultRequest: {cpu: 100m, memory: 128Mi}
    default: {memory: 256Mi}          # default *limit*
    max: {memory: 512Mi}
```
```bash
kubectl apply -f limitrange.yaml
kubectl -n team-red rollout restart deploy worker      # optional: the ReplicaSet also retries on its own, with back-off
kubectl -n team-red get pods
kubectl -n team-red get quota team-red-quota -o jsonpath='{.status.used.requests\.memory}' > {{ANSWERS}}/quota-used.txt   # 512Mi
```
Docs: *Policies → Limit Ranges* and *Resource Quotas*.
**Pitfalls:** once a quota covers `requests.*`/`limits.*`, every new pod must state them — the LimitRange fills them in at admission.
LimitRanges only affect pods created **after** they exist. In a LimitRange, `default` = limit and `defaultRequest` = request.
