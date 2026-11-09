```bash
kubectl config use-context main
kubectl -n jobs get job nightly-export -o yaml > job.yaml     # the pod template of a Job is immutable, so you have to recreate it
kubectl -n jobs delete job nightly-export
vi job.yaml   # strip status/uid/selector/controller-uid labels, then move shipper:
```
```yaml
spec:
  backoffLimit: 2
  template:
    spec:
      restartPolicy: Never
      initContainers:
      - name: shipper
        image: busybox:1.37
        restartPolicy: Always          # ← this makes it a native sidecar
        command: ["sh", "-c", "tail -F /var/log/export/out.log"]
        volumeMounts: [{name: logs, mountPath: /var/log/export}]
      containers:
      - name: export
        ...
```
```bash
kubectl apply -f job.yaml
kubectl -n jobs wait --for=condition=Complete job/nightly-export
kubectl -n jobs logs job/nightly-export -c shipper
```
Docs: *Sidecar Containers* and *Jobs → Pod backoff failure policy*.

- A sidecar is an init container with `restartPolicy: Always`. It starts before the app containers and keeps running. The Job counts the
  pod as done once the regular containers exit, and the kubelet then stops the sidecar.
- When you export the YAML of an existing Job, remove the generated `selector` and the `controller-uid`/`batch.kubernetes.io/*` labels,
  or the API server rejects the new Job.
- `backoffLimit` counts retries before the Job is marked Failed. With `restartPolicy: Never`, each retry is a new pod. With `OnFailure`,
  the container restarts in the same pod.
