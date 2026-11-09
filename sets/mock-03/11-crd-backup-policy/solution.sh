# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
cat > "$FILES/nightly-orders.yaml" <<'YAML'
apiVersion: dataops.example.com/v1alpha1
kind: BackupPolicy
metadata:
  name: nightly-orders
  namespace: dataops
spec:
  schedule: "30 1 * * *"
  retentionDays: 30
  target:
    kind: PostgreSQL
    name: orders
YAML
retry kubectl --context alt patch crd backuppolicies.dataops.example.com --type=json -p='[
  {"op":"add","path":"/spec/names/shortNames","value":["bp"]},
  {"op":"add","path":"/spec/versions/0/additionalPrinterColumns","value":[
    {"name":"Schedule","type":"string","jsonPath":".spec.schedule"},
    {"name":"Retention","type":"integer","jsonPath":".spec.retentionDays"}]}]'
kubectl --context alt wait --for=condition=Established crd/backuppolicies.dataops.example.com --timeout=60s
retry kubectl --context alt apply -f "$FILES/nightly-orders.yaml"
