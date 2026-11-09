ns main erp; ns main finance
apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: erp-legacy, namespace: erp}
spec:
  containers:
  - name: erp
    image: $IMG_NGINX
    command: ["sh", "-c", "echo 'ERP 7.4 legacy' > /usr/share/nginx/html/index.html && exec nginx -g 'daemon off;'"]
    ports: [{containerPort: 80}]
YAML
kubectl --context main -n erp label pod erp-legacy run- >/dev/null 2>&1
kubectl --context main -n erp wait --for=condition=Ready pod/erp-legacy --timeout=120s >/dev/null
