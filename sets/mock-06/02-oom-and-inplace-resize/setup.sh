install_metrics_server main
ns main crunch
apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: importer, namespace: crunch}
spec:
  containers:
  - name: loader
    image: $IMG_POLINUX
    command: ["stress", "--vm", "1", "--vm-bytes", "200M", "--vm-hang", "0"]
    resources:
      requests: {memory: 64Mi}
      limits: {memory: 100Mi}
---
apiVersion: v1
kind: Pod
metadata: {name: cruncher, namespace: crunch}
spec:
  containers:
  - name: worker
    image: $IMG_POLINUX
    command: ["stress", "--cpu", "1"]
    resizePolicy:
    - {resourceName: cpu, restartPolicy: NotRequired}
    - {resourceName: memory, restartPolicy: RestartContainer}
    resources:
      requests: {cpu: 50m, memory: 32Mi}
      limits: {cpu: 100m, memory: 64Mi}
YAML
wait_for 120 pod_ready main cruncher crunch
wait_for 120 bash -c "[ \"\$(kubectl --context main -n crunch get pod importer -o jsonpath='{.status.containerStatuses[0].restartCount}')\" -ge 1 ]"
kubectl --context main -n crunch get pod cruncher -o jsonpath='{.metadata.uid}' > "$STATE/m06-q02-uid"
