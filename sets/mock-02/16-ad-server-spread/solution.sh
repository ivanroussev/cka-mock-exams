kubectl --context main create priorityclass ads-critical --value=100000 --description="ad server"
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: ad-server, namespace: ads}
spec:
  replicas: 4
  selector: {matchLabels: {app: ad-server}}
  template:
    metadata: {labels: {app: ad-server}}
    spec:
      priorityClassName: ads-critical
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: DoNotSchedule
        nodeTaintsPolicy: Honor
        labelSelector: {matchLabels: {app: ad-server}}
      containers:
      - name: nginx
        image: $IMG_NGINX
        resources: {requests: {cpu: 50m, memory: 32Mi}}
YAML
kubectl --context main -n ads rollout status deploy/ad-server --timeout=120s
