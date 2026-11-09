install_traefik alt
ns alt blog
# Certificate + key the learner turns into a TLS Secret.
openssl req -x509 -newkey rsa:2048 -nodes -days 365 -subj "/CN=blog.example.com" \
  -addext "subjectAltName=DNS:blog.example.com" -keyout "$FILES/blog.key" -out "$FILES/blog.crt" >/dev/null 2>&1
echo_app() { # echo_app <name> <text>
  apply alt <<YAML
apiVersion: v1
kind: ConfigMap
metadata: {name: $1-conf, namespace: blog}
data:
  default.conf: |
    server { listen 80; location / { default_type text/plain; return 200 "$2"; } }
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: $1, namespace: blog}
spec:
  replicas: 1
  selector: {matchLabels: {app: $1}}
  template:
    metadata: {labels: {app: $1}}
    spec:
      containers:
      - name: nginx
        image: $IMG_NGINX
        ports: [{containerPort: 80, name: http}]
        volumeMounts: [{name: conf, mountPath: /etc/nginx/conf.d}]
      volumes: [{name: conf, configMap: {name: $1-conf}}]
---
apiVersion: v1
kind: Service
metadata: {name: $1, namespace: blog}
spec:
  selector: {app: $1}
  ports: [{name: http, port: 80, targetPort: http}]
YAML
}
echo_app blog "blog home page"
echo_app blog-admin "blog admin panel"
for d in blog blog-admin; do kubectl --context alt -n blog rollout status deploy/$d --timeout=120s >/dev/null; done
