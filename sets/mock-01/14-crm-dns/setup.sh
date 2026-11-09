source "$TASK_DIR/../lib.sh"
ns main crm
echo_app main crm crm-db "crm-db"
kubectl --context main -n crm expose deploy crm-db --port 80 >/dev/null
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: crm-frontend, namespace: crm}
spec:
  replicas: 2
  selector: {matchLabels: {app: crm-frontend}}
  template:
    metadata: {labels: {app: crm-frontend}}
    spec:
      dnsPolicy: None
      dnsConfig:
        nameservers: [192.0.2.53]
        searches: [crm.corp.example]
        options: [{name: timeout, value: "1"}, {name: attempts, value: "1"}]
      containers: [{name: web, image: $IMG_NGINX}]
YAML
kubectl --context main -n crm rollout status deploy/crm-frontend --timeout=120s >/dev/null
