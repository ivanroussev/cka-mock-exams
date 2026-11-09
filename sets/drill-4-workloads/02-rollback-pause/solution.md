```bash
kubectl config use-context main
kubectl -n billing rollout history deploy/invoice-api                 # CHANGE-CAUSE shows what each revision was
kubectl -n billing rollout history deploy/invoice-api --revision=1    # shows the image of revision 1
kubectl -n billing rollout undo deploy/invoice-api --to-revision=1
kubectl -n billing rollout status deploy/invoice-api
kubectl -n billing get deploy invoice-api -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}' > {{ANSWERS}}/invoice-revision.txt   # 4
kubectl -n billing rollout pause deploy/invoice-api
kubectl -n billing set env deploy/invoice-api FEATURE_INVOICE_PDF=on
kubectl -n billing get pods            # same pods as before, nothing rolls out
```
- A rollback is a new rollout. Revision 1's template becomes **revision 4**, and revision 1 is gone from the history. So the answer is `4`, not `1`.
- Plain `rollout undo` (no flag) would go back to revision 2 (nginx 1.28), which isn't what the task asks for.
- While a Deployment is paused, template changes are saved but no new ReplicaSet is created. `kubectl rollout resume` starts the rollout later.
  `rollout undo` doesn't work on a paused Deployment, so roll back **before** pausing.
