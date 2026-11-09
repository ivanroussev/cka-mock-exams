ns main compliance
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: audit-relay, namespace: compliance}
spec:
  replicas: 3
  selector: {matchLabels: {app: audit-relay}}
  template:
    metadata: {labels: {app: audit-relay, tier: audit}}
    spec:
      containers:
      - name: relay
        image: $IMG_BUSYBOX
        command:
        - sh
        - -c
        - |
          echo "ALLOWED user=alice res=/reports pod=\$HOSTNAME"
          echo "DENIED user=mallory res=/admin pod=\$HOSTNAME"
          echo "ALLOWED user=bob res=/billing pod=\$HOSTNAME"
          echo "DENIED user=eve res=/secrets pod=\$HOSTNAME"
          case "\$HOSTNAME" in *[0-4]) echo "DENIED user=trent res=/payroll pod=\$HOSTNAME";; esac
          while true; do sleep 3600; done
YAML
kubectl --context main -n compliance rollout status deploy/audit-relay --timeout=120s >/dev/null
