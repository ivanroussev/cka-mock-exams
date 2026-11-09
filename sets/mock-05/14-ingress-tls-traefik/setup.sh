install_traefik main
ns main docs
openssl req -x509 -newkey rsa:2048 -nodes -keyout "$FILES/docs.key" -out "$FILES/docs.crt" -days 365 \
  -subj "/CN=docs.example.internal" -addext "subjectAltName=DNS:docs.example.internal" >/dev/null 2>&1
for app in docs-web:80:"docs portal home" docs-api:8080:"docs api ok"; do
  name="${app%%:*}"; rest="${app#*:}"; port="${rest%%:*}"; body="${rest#*:}"
  apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: $name, namespace: docs}
spec:
  replicas: 1
  selector: {matchLabels: {app: $name}}
  template:
    metadata: {labels: {app: $name}}
    spec:
      containers:
      - name: web
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "mkdir -p /www/api && echo '$body' > /www/index.html && cp /www/index.html /www/api/index.html && exec httpd -f -p $port -h /www"]
        ports: [{containerPort: $port}]
---
apiVersion: v1
kind: Service
metadata: {name: $name, namespace: docs}
spec:
  selector: {app: $name}
  ports: [{port: $port, targetPort: $port}]
YAML
done
kubectl --context main -n docs rollout status deploy/docs-api --timeout=120s >/dev/null
