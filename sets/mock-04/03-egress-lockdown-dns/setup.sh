ns main orders; ns main stock; ns main audit
for app in inventory warehouse; do
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: $app, namespace: stock}
spec:
  replicas: 1
  selector: {matchLabels: {app: $app}}
  template:
    metadata: {labels: {app: $app}}
    spec:
      containers:
      - name: web
        image: $IMG_NGINX
        command: ["sh", "-c", "echo '$app service' > /usr/share/nginx/html/index.html && exec nginx -g 'daemon off;'"]
        ports: [{containerPort: 80}]
---
apiVersion: v1
kind: Service
metadata: {name: $app, namespace: stock}
spec:
  selector: {app: $app}
  ports: [{port: 8080, targetPort: 80}]
YAML
done
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: order-worker, namespace: orders}
spec:
  replicas: 1
  selector: {matchLabels: {app: order-worker}}
  template:
    metadata: {labels: {app: order-worker}}
    spec:
      containers:
      - name: worker
        image: $IMG_CURL
        command: ["sh", "-c", "while true; do if out=\$(curl -s -m 3 http://inventory.stock:8080); then echo \"\$(date +%T) inventory ok: \$out\"; else echo \"\$(date +%T) inventory unreachable\"; fi; sleep 5; done"]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: egress-lockdown, namespace: orders}
spec:
  podSelector: {}
  policyTypes: [Egress]
  egress:
  - to:
    - namespaceSelector: {matchLabels: {kubernetes.io/metadata.name: stock}}
      podSelector: {matchLabels: {app: inventory}}
    ports: [{protocol: TCP, port: 8080}]
YAML
kubectl --context main -n audit run audit-sink --image="$IMG_NGINX" --port=80 >/dev/null
kubectl --context main -n stock rollout status deploy/inventory --timeout=120s >/dev/null
kubectl --context main -n stock rollout status deploy/warehouse --timeout=120s >/dev/null
kubectl --context main -n orders rollout status deploy/order-worker --timeout=120s >/dev/null
kubectl --context main -n audit wait --for=condition=Ready pod/audit-sink --timeout=120s >/dev/null
