ns main ledger
ns main billing
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: ledger-api, namespace: ledger}
spec:
  replicas: 2
  selector: {matchLabels: {app: ledger-api}}
  template:
    metadata: {labels: {app: ledger-api}}
    spec:
      topologySpreadConstraints:
      - {maxSkew: 1, topologyKey: kubernetes.io/hostname, whenUnsatisfiable: ScheduleAnyway, labelSelector: {matchLabels: {app: ledger-api}}}
      containers: [{name: httpd, image: $IMG_HTTPD, ports: [{containerPort: 80}]}]
---
apiVersion: v1
kind: Service
metadata: {name: ledger-api, namespace: ledger}
spec:
  selector: {app: ledger-api}
  ports: [{port: 80, targetPort: 80}]
---
apiVersion: v1
kind: Pod
metadata: {name: invoicer, namespace: billing, labels: {app: invoicer}}
spec:
  containers:
  - name: invoicer
    image: $IMG_CURL
    command: ["sleep", "86400"]
    env: [{name: LEDGER_URL, value: "http://ledger-api:80"}]
YAML
kubectl --context main -n ledger rollout status deploy/ledger-api --timeout=120s >/dev/null
kubectl --context main -n billing wait --for=condition=Ready pod/invoicer --timeout=120s >/dev/null
