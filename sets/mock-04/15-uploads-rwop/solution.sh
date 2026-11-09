# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
retry kubectl --context main -n uploads scale deploy uploader --replicas=0
retry kubectl --context main -n uploads delete pvc uploads-data --wait=true
apply main <<'YAML'
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: uploads-data, namespace: uploads}
spec:
  storageClassName: standard
  accessModes: [ReadWriteOncePod]
  resources: {requests: {storage: 2Gi}}
YAML
retry kubectl --context main -n uploads patch deploy uploader --type=json -p='[{"op":"replace","path":"/spec/strategy","value":{"type":"Recreate"}}]'
retry kubectl --context main -n uploads scale deploy uploader --replicas=1
kubectl --context main -n uploads rollout status deploy/uploader --timeout=180s
