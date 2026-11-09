```bash
kubectl config use-context main
kubectl -n quotes set image deploy/quote-api web=nginx:1.28-alpine
kubectl -n quotes annotate deploy/quote-api kubernetes.io/change-cause="upgrade to nginx 1.28" --overwrite
kubectl -n quotes scale deploy/quote-api --replicas=3
kubectl -n quotes rollout status deploy/quote-api
kubectl -n quotes rollout history deploy/quote-api
```
**Notes:** `--record` is gone; the change cause is just the `kubernetes.io/change-cause` annotation, copied onto the
ReplicaSet of the current revision. Annotate right after `set image` (before the next change) so it lands on the new revision.
`set image` needs the **container** name (`web=`), not the Deployment name.
