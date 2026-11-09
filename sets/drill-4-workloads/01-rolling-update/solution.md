```bash
kubectl config use-context main
kubectl -n rollout patch deploy storefront -p '{"spec":{"strategy":{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0}}}}'
#   (or: kubectl -n rollout edit deploy storefront → spec.strategy.rollingUpdate)
kubectl -n rollout set image deploy/storefront nginx=nginx:1.28-alpine
kubectl -n rollout annotate deploy/storefront kubernetes.io/change-cause="upgrade nginx to 1.28" --overwrite
kubectl -n rollout rollout status deploy/storefront
kubectl -n rollout rollout history deploy/storefront          # REVISION 2 → upgrade nginx to 1.28
kubectl -n rollout get deploy storefront -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}' > {{ANSWERS}}/storefront-revision.txt
```
Docs: *Deployments → Updating a Deployment / Rolling Back a Deployment*.

- Only changes to `spec.template` create a new revision. Editing the strategy or adding an annotation doesn't, so the image change is the
  one that creates revision 2.
- `--record` is gone. The `kubernetes.io/change-cause` annotation on the Deployment is copied to the current ReplicaSet, and that's what
  `rollout history` shows. `--overwrite` is needed because the annotation already exists.
- `maxSurge: 1, maxUnavailable: 0` means "add one new pod, wait until it's Ready, then remove one old pod", so capacity never drops.
