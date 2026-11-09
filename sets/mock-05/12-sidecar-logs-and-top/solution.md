```bash
kubectl -n audit edit deploy ledger-writer
```
```yaml
    spec:
      initContainers:                 # native sidecar = init container with restartPolicy: Always (v1.29+)
      - name: log-shipper
        image: busybox:1.37
        restartPolicy: Always
        command: ["sh", "-c", "touch /var/log/app/app.log; exec tail -n +1 -F /var/log/app/app.log"]
        volumeMounts: [{name: logs, mountPath: /var/log/app}]
```
```bash
kubectl -n audit rollout status deploy/ledger-writer
kubectl -n audit logs deploy/ledger-writer -c log-shipper | grep ERROR > {{ANSWERS}}/errors.txt
kubectl -n audit top pod analytics --containers          # transcoder ~1000m
echo transcoder > {{ANSWERS}}/hungry-container.txt
```
Docs: *Workloads → Pods → Sidecar containers*, and *Logging Architecture* (streaming sidecar).
**Pitfalls:** a sidecar in `containers:` would also work but has no start-order guarantee — the task asks for a native one.
`tail -f` without `-n +1` only shows the last 10 lines, and the ERROR lines are at the top. `kubectl top pod` without `--containers`
only shows the pod total.
