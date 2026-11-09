ns main resize
apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: analytics, namespace: resize}
spec:
  containers:
  - name: analytics
    image: $IMG_NGINX
    resizePolicy:
    - {resourceName: cpu, restartPolicy: NotRequired}
    - {resourceName: memory, restartPolicy: RestartContainer}
    resources:
      requests: {cpu: 100m, memory: 64Mi}
      limits: {cpu: 200m, memory: 128Mi}
YAML
kubectl --context main -n resize wait --for=condition=Ready pod/analytics --timeout=120s >/dev/null
# Remember the UID so the check can tell whether the pod was recreated.
kubectl --context main -n resize get pod analytics -o jsonpath='{.metadata.uid}' > "$STATE/drill4-analytics-uid"
