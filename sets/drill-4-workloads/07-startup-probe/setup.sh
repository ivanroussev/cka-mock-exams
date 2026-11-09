ns main probes
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: ledger-ui, namespace: probes}
spec:
  replicas: 2
  selector: {matchLabels: {app: ledger-ui}}
  template:
    metadata: {labels: {app: ledger-ui}}
    spec:
      containers:
      - name: web
        image: $IMG_NGINX
        command: ["sh", "-c", "echo warming up caches; sleep 40; exec nginx -g 'daemon off;'"]
        ports: [{containerPort: 80}]
        livenessProbe:
          httpGet: {path: /, port: 80}
          periodSeconds: 5
          failureThreshold: 3
YAML
# Wait until the liveness probe has killed the containers at least once, so the breakage is visible.
wait_for 150 bash -c '[ "$(kubectl --context main -n probes get pods -l app=ledger-ui -o jsonpath="{.items[*].status.containerStatuses[0].restartCount}" | tr " " "\n" | awk "\$1>=1" | wc -l | tr -d " ")" -ge 2 ]'
