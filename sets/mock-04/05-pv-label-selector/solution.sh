# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
apply main <<YAML
apiVersion: v1
kind: PersistentVolume
metadata: {name: media-fast, labels: {tier: fast}}
spec:
  capacity: {storage: 2Gi}
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ""
  hostPath: {path: /srv/media-fast, type: DirectoryOrCreate}
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions: [{key: kubernetes.io/hostname, operator: In, values: [$MAIN_W1]}]
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: media-claim, namespace: media}
spec:
  storageClassName: ""
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 1Gi}}
  selector: {matchLabels: {tier: fast}}
---
apiVersion: v1
kind: Pod
metadata: {name: media-writer, namespace: media}
spec:
  containers:
  - name: writer
    image: busybox:1.37
    command: ["sh", "-c", "echo ready > /media/status && sleep 3600"]
    volumeMounts: [{name: media, mountPath: /media}]
  volumes:
  - name: media
    persistentVolumeClaim: {claimName: media-claim}
YAML
kubectl --context main -n media wait --for=condition=Ready pod/media-writer --timeout=120s
