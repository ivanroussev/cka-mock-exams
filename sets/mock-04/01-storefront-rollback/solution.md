```bash
kubectl config use-context main
kubectl -n web-shop rollout status deploy storefront     # waiting… new replicas have been updated
kubectl -n web-shop get pods                             # ImagePullBackOff: nginx:1.28-alpine-perf doesn't exist
kubectl -n web-shop rollout history deploy storefront
#   1 initial release · 2 upgrade to nginx 1.28 · 3 switch to perf build
kubectl -n web-shop rollout history deploy storefront --revision=2     # image nginx:1.28-alpine
echo 2 > {{ANSWERS}}/storefront-good-revision.txt
kubectl -n web-shop rollout undo deploy storefront --to-revision=2     # becomes revision 4
kubectl -n web-shop edit deploy storefront
```
```yaml
spec:
  minReadySeconds: 10
  progressDeadlineSeconds: 120
  strategy:
    type: RollingUpdate
    rollingUpdate: {maxSurge: 1, maxUnavailable: 0}
```
```bash
kubectl -n web-shop set env deploy storefront -c web THEME=winter
kubectl -n web-shop annotate deploy storefront kubernetes.io/change-cause="enable winter theme" --overwrite
kubectl -n web-shop rollout status deploy storefront
kubectl -n web-shop rollout history deploy storefront     # 5  enable winter theme
```
**Notes:** a plain `rollout undo` goes back one revision — here that happens to be 2 as well, but `--to-revision` is explicit.
`--record` is deprecated; the `kubernetes.io/change-cause` annotation is what `rollout history` shows. Editing the strategy alone
doesn't start a rollout (only `.spec.template` changes do).
