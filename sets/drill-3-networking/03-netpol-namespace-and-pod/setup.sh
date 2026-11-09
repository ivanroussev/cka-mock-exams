ns main inventory
ns main storefront
ns main partners
kubectl --context main label ns storefront team=shop --overwrite >/dev/null
apply main <<YAML
apiVersion: v1
kind: ConfigMap
metadata: {name: stock-api-conf, namespace: inventory}
data:
  default.conf: |
    server {
      listen 80;
      listen 9090;
      location / { default_type text/plain; return 200 "stock-api ok"; }
    }
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: stock-api, namespace: inventory}
spec:
  replicas: 1
  selector: {matchLabels: {app: stock-api}}
  template:
    metadata: {labels: {app: stock-api}}
    spec:
      containers:
      - name: nginx
        image: $IMG_NGINX
        ports: [{containerPort: 80, name: http}, {containerPort: 9090, name: metrics}]
        volumeMounts: [{name: conf, mountPath: /etc/nginx/conf.d}]
      volumes: [{name: conf, configMap: {name: stock-api-conf}}]
---
apiVersion: v1
kind: Service
metadata: {name: stock-api, namespace: inventory}
spec:
  selector: {app: stock-api}
  ports:
  - {name: http, port: 80, targetPort: 80}
  - {name: metrics, port: 9090, targetPort: 9090}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: stock-ingress, namespace: inventory}
spec:
  podSelector:
    matchLabels: {app: stock-api}
  policyTypes: [Ingress]
  ingress:
  - from:
    - namespaceSelector:
        matchLabels: {team: shop}
    - podSelector:
        matchLabels: {role: checkout}
YAML
kubectl --context main -n inventory rollout status deploy/stock-api --timeout=120s >/dev/null
