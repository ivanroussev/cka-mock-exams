ns main storefront; ns main inventory
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: catalog, namespace: inventory}
spec:
  replicas: 1
  selector: {matchLabels: {app: catalog}}
  template:
    metadata: {labels: {app: catalog}}
    spec:
      containers:
      - name: web
        image: $IMG_NGINX
        command: ["sh", "-c", "echo 'catalog: 1204 products' > /usr/share/nginx/html/index.html && exec nginx -g 'daemon off;'"]
---
apiVersion: v1
kind: Service
metadata: {name: catalog, namespace: inventory}
spec:
  selector: {app: catalog}
  ports: [{port: 80}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: frontend, namespace: storefront}
spec:
  replicas: 2
  selector: {matchLabels: {app: frontend}}
  template:
    metadata: {labels: {app: frontend}}
    spec:
      dnsPolicy: None
      dnsConfig:
        nameservers: [10.96.0.53]
        searches: [storefront.svc.cluster.local, svc.cluster.local, cluster.local]
        options: [{name: ndots, value: "5"}, {name: timeout, value: "1"}]
      containers:
      - name: frontend
        image: $IMG_CURL
        command: ["sh", "-c", "while true; do if out=\$(curl -s -m 3 http://catalog 2>&1); then echo \"\$(date +%T) \$out\"; else echo \"\$(date +%T) could not resolve catalog\"; fi; sleep 5; done"]
YAML
kubectl --context main -n storefront rollout status deploy/frontend --timeout=120s >/dev/null
kubectl --context main -n inventory rollout status deploy/catalog --timeout=120s >/dev/null
