ns main quotes
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: quotes, namespace: quotes}
spec:
  replicas: 2
  selector: {matchLabels: {app: quotes}}
  template:
    metadata: {labels: {app: quotes}}
    spec:
      containers:
      - name: web
        image: $IMG_NGINX
        command: ["sh", "-c", "echo ok > /usr/share/nginx/html/healthz && exec nginx -g 'daemon off;'"]
        ports: [{name: http, containerPort: 80}]
        readinessProbe:
          httpGet: {path: /healthz, port: 8080}
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata: {name: quotes, namespace: quotes}
spec:
  selector: {app: quotes}
  ports: [{name: web, port: 80, targetPort: web}]
YAML
wait_for 90 bash -c "[ \$(kubectl --context main -n quotes get pods -l app=quotes --field-selector=status.phase=Running -o name | wc -l) -eq 2 ]"
