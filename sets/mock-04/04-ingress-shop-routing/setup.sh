install_traefik main
ns main shop
for app in web api assets; do
apply main <<YAML
apiVersion: v1
kind: ConfigMap
metadata: {name: $app-conf, namespace: shop}
data:
  default.conf: |
    server {
      listen 80;
      location / { default_type text/plain; return 200 "shop-$app \$request_uri"; }
    }
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: $app, namespace: shop}
spec:
  replicas: 1
  selector: {matchLabels: {app: shop, component: $app}}
  template:
    metadata: {labels: {app: shop, component: $app}}
    spec:
      containers:
      - name: nginx
        image: $IMG_NGINX
        ports: [{containerPort: 80, name: http}]
        volumeMounts: [{name: conf, mountPath: /etc/nginx/conf.d}]
      volumes: [{name: conf, configMap: {name: $app-conf}}]
YAML
done
apply main <<'YAML'
apiVersion: v1
kind: Service
metadata: {name: web, namespace: shop}
spec:
  selector: {app: shop, component: web}
  ports: [{port: 80, targetPort: http}]
---
apiVersion: v1
kind: Service
metadata: {name: api, namespace: shop}
spec:
  selector: {app: shop, component: api}
  ports: [{port: 8080, targetPort: http}]
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: {name: shop, namespace: shop}
spec:
  ingressClassName: nginx
  rules:
  - host: shop.example.com
    http:
      paths:
      - {path: /api, pathType: Exact, backend: {service: {name: api, port: {number: 8080}}}}
      - {path: /, pathType: Prefix, backend: {service: {name: web, port: {number: 80}}}}
YAML
for app in web api assets; do kubectl --context main -n shop rollout status deploy/$app --timeout=120s >/dev/null; done
