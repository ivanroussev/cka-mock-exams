apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: ram-share, namespace: scratch}
spec:
  volumes:
  - name: cache
    emptyDir: {medium: Memory, sizeLimit: 64Mi}
  containers:
  - name: writer
    image: $IMG_BUSYBOX
    command: ["sh", "-c", "echo ready > /cache/status; sleep 3600"]
    volumeMounts: [{name: cache, mountPath: /cache}]
  - name: reader
    image: $IMG_BUSYBOX
    command: ["sleep", "3600"]
    volumeMounts: [{name: cache, mountPath: /data, readOnly: true}]
YAML
kubectl --context main -n scratch wait --for=condition=Ready pod/ram-share --timeout=90s
sleep 2
