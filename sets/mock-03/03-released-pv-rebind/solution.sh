# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
retry kubectl --context main patch pv records-archive --type=json -p='[{"op":"remove","path":"/spec/claimRef"}]'
apply main <<'YAML'
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: archive-data, namespace: records}
spec:
  storageClassName: archive
  volumeName: records-archive
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 2Gi}}
---
apiVersion: v1
kind: Pod
metadata: {name: archive-reader, namespace: records}
spec:
  containers:
  - name: reader
    image: busybox:1.37
    command: ["sleep", "3600"]
    volumeMounts: [{name: archive, mountPath: /archive, readOnly: true}]
  volumes:
  - name: archive
    persistentVolumeClaim: {claimName: archive-data}
YAML
kubectl --context main -n records wait --for=condition=Ready pod/archive-reader --timeout=120s
