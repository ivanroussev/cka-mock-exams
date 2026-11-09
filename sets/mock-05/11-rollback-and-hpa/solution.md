```bash
kubectl -n web-portal rollout status deploy/portal          # stuck: ImagePullBackOff on the new pods
kubectl -n web-portal rollout history deploy/portal         # CHANGE-CAUSE column shows the annotation per revision
kubectl -n web-portal rollout history deploy/portal --revision=2    # check image + env before you roll back
kubectl -n web-portal rollout undo deploy/portal --to-revision=2
kubectl -n web-portal rollout status deploy/portal

kubectl -n web-portal set resources deploy/portal -c nginx --requests=cpu=100m,memory=64Mi --limits=cpu=200m
kubectl -n web-portal rollout status deploy/portal

kubectl -n web-portal autoscale deploy portal --name=portal --min=2 --max=6 --cpu=60% --dry-run=client -o yaml > hpa.yaml
vim hpa.yaml      # add under spec:
#   behavior:
#     scaleDown:
#       stabilizationWindowSeconds: 120
kubectl apply -f hpa.yaml
kubectl -n web-portal get hpa portal              # TARGETS shows cpu: x%/60%, not <unknown>
kubectl -n web-portal describe hpa portal         # ScalingActive True
```
Docs: *Horizontal Pod Autoscaling → Configurable scaling behavior*.
**Pitfalls:** `rollout undo` without `--to-revision` goes back one step (to "enable response cache"). After an undo, the old revision
is re-numbered as the newest one. The HPA computes utilisation against **requests** — without a CPU request it stays `<unknown>`.
(On older kubectl, `autoscale` uses `--cpu-percent=60`.)
