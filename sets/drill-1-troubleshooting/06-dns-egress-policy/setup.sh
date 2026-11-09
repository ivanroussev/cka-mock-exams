ns main orders
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: inventory, namespace: orders}
spec:
  replicas: 1
  selector: {matchLabels: {app: inventory}}
  template:
    metadata: {labels: {app: inventory}}
    spec:
      containers: [{name: nginx, image: $IMG_NGINX, ports: [{containerPort: 80}]}]
---
apiVersion: v1
kind: Service
metadata: {name: inventory, namespace: orders}
spec:
  selector: {app: inventory}
  ports: [{port: 80, targetPort: 80}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: legacy, namespace: orders}
spec:
  replicas: 1
  selector: {matchLabels: {app: legacy}}
  template:
    metadata: {labels: {app: legacy}}
    spec:
      containers: [{name: httpd, image: $IMG_HTTPD, ports: [{containerPort: 80}]}]
---
apiVersion: v1
kind: Service
metadata: {name: legacy, namespace: orders}
spec:
  selector: {app: legacy}
  ports: [{port: 80, targetPort: 80}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: checkout, namespace: orders}
spec:
  replicas: 1
  selector: {matchLabels: {app: checkout}}
  template:
    metadata: {labels: {app: checkout}}
    spec:
      containers: [{name: client, image: $IMG_CURL, command: ["sleep", "infinity"]}]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: checkout-egress, namespace: orders}
spec:
  podSelector: {matchLabels: {app: checkout}}
  policyTypes: [Egress]
  egress:
  - to:
    - podSelector: {matchLabels: {app: inventory}}
    ports:
    - {protocol: TCP, port: 80}
YAML
for d in inventory legacy checkout; do kubectl --context main -n orders rollout status deploy/$d --timeout=120s >/dev/null; done
