ns main shop-prod; ns main shop-frontend; ns main shop-tools
kubectl --context main label ns shop-frontend team=front-end --overwrite >/dev/null
kubectl --context main label ns shop-tools team=tools --overwrite >/dev/null
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: catalog, namespace: shop-prod}
spec:
  replicas: 3
  selector: {matchLabels: {app: catalog}}
  template:
    metadata: {labels: {app: catalog, tier: backend}}
    spec:
      containers:
      - name: nginx
        image: $IMG_NGINX
        ports: [{name: http, containerPort: 80}]
        readinessProbe:
          httpGet: {path: /healthz, port: http}
          periodSeconds: 3
---
apiVersion: v1
kind: Service
metadata: {name: catalog, namespace: shop-prod}
spec:
  selector: {app: catalogue}
  ports: [{port: 80, targetPort: http}]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: catalog-ingress, namespace: shop-prod}
spec:
  podSelector: {matchLabels: {app: catalog}}
  policyTypes: [Ingress]
  ingress:
  - from:
    - namespaceSelector: {matchLabels: {team: frontend}}
    ports: [{protocol: TCP, port: 80}]
---
apiVersion: v1
kind: Pod
metadata: {name: storefront, namespace: shop-frontend, labels: {app: storefront}}
spec:
  containers: [{name: shell, image: $IMG_BUSYBOX, command: ["sleep", "infinity"]}]
YAML
wait_for 120 pod_ready main storefront shop-frontend
