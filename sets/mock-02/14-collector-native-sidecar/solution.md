```bash
kubectl config use-context main
kubectl -n ingest edit deploy collector        # docs: search "Sidecar Containers"
```
```yaml
    spec:
      volumes:
      - name: logs
        emptyDir: {}
      initContainers:
      - name: log-shipper
        image: busybox:1.37
        restartPolicy: Always          # ← this makes it a native sidecar
        command: ["tail", "-F", "/var/log/collector/app.log"]
        env:
        - name: SHIP_TOKEN
          valueFrom:
            secretKeyRef:
              name: shipper-creds
              key: token
        volumeMounts:
        - name: logs
          mountPath: /var/log/collector
      containers:
      - name: app
        ...
        volumeMounts:
        - name: logs
          mountPath: /var/log/collector
```
```bash
kubectl -n ingest rollout status deploy collector
kubectl -n ingest get pods                     # READY 2/2
kubectl -n ingest logs deploy/collector -c log-shipper
```
**Notes:** a native sidecar is an entry in `initContainers` with `restartPolicy: Always`: it starts before the app
containers, keeps running, and doesn't block pod completion for Jobs. Without `restartPolicy: Always` the pod would hang
in `Init:0/1` because `tail -F` never exits. `tail -F` (capital F) keeps retrying until the file exists.
