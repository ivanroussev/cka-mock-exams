```bash
kubectl config use-context main
kubectl -n invoicing get pods                            # CrashLoopBackOff
kubectl -n invoicing logs deploy/pdf-renderer --previous # or: logs <pod> -p
kubectl -n invoicing logs deploy/pdf-renderer -p | grep FATAL > {{ANSWERS}}/pdf-renderer-error.txt
kubectl -n invoicing get cm pdf-renderer-config -o yaml
kubectl -n invoicing edit deploy pdf-renderer
```
```yaml
        env:
        - name: RENDER_QUEUE
          valueFrom:
            configMapKeyRef:
              name: pdf-renderer-config
              key: queue.name
```
```bash
kubectl -n invoicing rollout status deploy/pdf-renderer
kubectl -n invoicing logs deploy/pdf-renderer      # subscribed to queue=invoices-high
```
**Notes:** the variable name (`RENDER_QUEUE`) differs from the key (`queue.name`), so `envFrom` doesn't help — it would
create variables named after the keys. Use one `env` entry with `valueFrom.configMapKeyRef`. `--previous` (`-p`) shows the
output of the run that crashed; on a Deployment, `kubectl logs deploy/<name>` picks one of its pods.
