node_exec "$MAIN_W1" "rm -f /etc/kubernetes/manifests/node-agent.yaml"
ns main edge-cache
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: edge-cache, namespace: edge-cache}
spec:
  replicas: 3
  selector: {matchLabels: {app: edge-cache}}
  template:
    metadata: {labels: {app: edge-cache}}
    spec:
      containers: [{name: cache, image: $IMG_REDIS}]
YAML
kubectl --context main -n edge-cache rollout status deploy/edge-cache --timeout=120s >/dev/null
