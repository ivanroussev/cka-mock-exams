install_traefik main
ns main media
for app in images:"image store" videos:"video store"; do
  name="${app%%:*}"; body="${app#*:}"
  apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: $name, namespace: media}
spec:
  replicas: 1
  selector: {matchLabels: {app: $name}}
  template:
    metadata: {labels: {app: $name}}
    spec:
      containers:
      - name: web
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "mkdir -p /www/$name && echo '$body' > /www/index.html && echo '$body: logo.png' > /www/$name/logo.png && echo '$body: intro.mp4' > /www/$name/intro.mp4 && exec httpd -f -p 8080 -h /www"]
        ports: [{containerPort: 8080}]
---
apiVersion: v1
kind: Service
metadata: {name: $name, namespace: media}
spec:
  selector: {app: $name}
  ports: [{name: web, port: 80, targetPort: 8080}]
YAML
done
apply main <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: {name: media, namespace: media}
spec:
  ingressClassName: nginx
  rules:
  - host: media.example.internal
    http:
      paths:
      - path: /images
        pathType: Exact
        backend: {service: {name: images, port: {name: http}}}
      - path: /videos
        pathType: Prefix
        backend: {service: {name: videos, port: {number: 8080}}}
YAML
kubectl --context main -n media rollout status deploy/videos --timeout=120s >/dev/null
