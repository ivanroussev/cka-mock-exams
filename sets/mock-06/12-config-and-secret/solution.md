```bash
kubectl -n billing-app create cm billing-config --from-file={{FILES}}/billing.properties --from-literal=LOG_LEVEL=debug
kubectl -n billing-app create secret generic billing-db --from-literal=DB_USER=billing --from-literal='DB_PASSWORD=S3cure!pass' \
  --dry-run=client -o yaml > secret.yaml
echo 'immutable: true' >> secret.yaml && kubectl apply -f secret.yaml
kubectl -n billing-app edit deploy billing
```
```yaml
    spec:
      containers:
      - name: app
        env:
        - name: LOG_LEVEL
          valueFrom: {configMapKeyRef: {name: billing-config, key: LOG_LEVEL}}
        envFrom:
        - secretRef: {name: billing-db}
        volumeMounts:
        - {name: config, mountPath: /etc/billing}
      volumes:
      - name: config
        configMap:
          name: billing-config
          items: [{key: billing.properties, path: billing.properties}]   # project only this key
```
```bash
kubectl -n billing-app exec deploy/billing -- env | grep -E 'LOG_LEVEL|DB_'
kubectl -n billing-app exec deploy/billing -- ls /etc/billing
```
**Pitfalls:** single-quote `'S3cure!pass'` in the shell (`!` triggers history expansion in bash). Without `items:`, every key —
including `LOG_LEVEL` — would appear as a file in `/etc/billing`. An immutable Secret can't be edited, only deleted and recreated.
