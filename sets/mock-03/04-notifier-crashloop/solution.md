```bash
kubectl config use-context main
kubectl -n alerts get pods
kubectl -n alerts logs deploy/notifier --previous          # or: logs <pod> -p
kubectl -n alerts logs deploy/notifier -p | grep FATAL > {{ANSWERS}}/notifier-fatal.txt
kubectl -n alerts get secret smtp-credentials -o jsonpath='{.data}'   # keys: password, username — not "smtp-password"
kubectl -n alerts edit deploy notifier
```
```yaml
        env:
        - name: SMTP_PASSWORD
          valueFrom:
            secretKeyRef: {name: smtp-credentials, key: password}   # was key: smtp-password (optional: true hid the error)
        envFrom:
        - configMapRef: {name: notifier-config}
```
After the first fix the pod crashes again with `FATAL: SMTP_HOST/SMTP_PORT not configured` — always re-read the logs after each fix.
Shortcut for the second part: `kubectl -n alerts set env deploy/notifier --from=configmap/notifier-config` (that adds one
`configMapKeyRef` entry per key — also accepted, but `envFrom` picks up keys added later too).

**Pitfall:** `optional: true` on a `secretKeyRef` turns a wrong key name into an *empty* variable instead of a
`CreateContainerConfigError`, so the problem only shows up in the application's logs.
