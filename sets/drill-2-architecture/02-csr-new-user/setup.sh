ns main audit
apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: ledger-sync, namespace: audit}
spec:
  containers: [{name: app, image: $IMG_BUSYBOX, command: ["sh", "-c", "while true; do echo synced; sleep 30; done"]}]
YAML
# A leftover user entry from an earlier run must not exist.
kubectl config delete-user mira >/dev/null 2>&1 || true
kubectl config delete-context mira@main >/dev/null 2>&1 || true
