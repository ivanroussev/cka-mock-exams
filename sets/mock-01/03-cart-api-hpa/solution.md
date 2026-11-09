Start imperatively, then add the `behavior` block (not available as flags):
```bash
kubectl config use-context main
kubectl -n checkout autoscale deploy cart-api --min=2 --max=8 --cpu=65% --dry-run=client -o yaml > hpa.yaml
vim hpa.yaml      # add spec.behavior (docs: search "HorizontalPodAutoscaler walkthrough" / "Configurable scaling behavior")
```
```yaml
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 180
      policies:
      - type: Pods
        value: 1
        periodSeconds: 60
```
```bash
kubectl apply -f hpa.yaml
kubectl -n checkout describe hpa cart-api
```
**Notes:** write `--cpu=65%` — **with** the percent sign. `--cpu=65` means an average *value* of 65 millicores, not 65% utilisation.
(Older kubectl versions use `--cpu-percent=65`.) `behavior` sits under `spec`, not under
`metrics`. Policy `type: Pods` limits by pod count; `type: Percent` would limit by percentage.
