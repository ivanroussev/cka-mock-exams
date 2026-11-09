kubectl --context main -n catalog expose deploy catalog-web --name=catalog --port=8080 --target-port=web >/dev/null
apply main <<'YAML'
apiVersion: v1
kind: Service
metadata: {name: catalog-ext, namespace: catalog}
spec:
  type: NodePort
  selector: {app: catalog-web}
  ports: [{port: 80, targetPort: web, nodePort: 30480}]
YAML
