ns main checkout
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: cart-api, namespace: checkout}
spec:
  replicas: 1
  selector: {matchLabels: {app: cart-api}}
  template:
    metadata: {labels: {app: cart-api}}
    spec:
      containers:
      - name: api
        image: $IMG_NGINX
        resources: {requests: {cpu: 50m, memory: 32Mi}}
YAML
