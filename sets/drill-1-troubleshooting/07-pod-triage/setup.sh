ns main triage
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: ledger, namespace: triage}
spec:
  replicas: 1
  selector: {matchLabels: {app: ledger}}
  template:
    metadata: {labels: {app: ledger}}
    spec:
      containers:
      - name: app
        image: $IMG_POLINUX
        command: ["stress", "--vm", "1", "--vm-bytes", "96M", "--vm-hang", "0"]
        resources: {requests: {memory: 32Mi}, limits: {memory: 48Mi}}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: catalog, namespace: triage}
spec:
  replicas: 1
  selector: {matchLabels: {app: catalog}}
  template:
    metadata: {labels: {app: catalog}}
    spec:
      containers: [{name: app, image: "nginx:1.27-alpinee"}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: gateway, namespace: triage}
spec:
  replicas: 1
  selector: {matchLabels: {app: gateway}}
  template:
    metadata: {labels: {app: gateway}}
    spec:
      containers:
      - name: app
        image: $IMG_NGINX
        ports: [{containerPort: 80}]
        readinessProbe: {httpGet: {path: /healthz, port: 80}, periodSeconds: 3}
        livenessProbe: {httpGet: {path: /healthz, port: 80}, periodSeconds: 5, failureThreshold: 3}
YAML
wait_for 150 bash -c "kubectl --context main -n triage get pods -l app=ledger -o jsonpath='{.items[*].status.containerStatuses[0].lastState.terminated.reason}' | grep -q OOMKilled"
wait_for 90 bash -c "kubectl --context main -n triage get pods -l app=catalog -o jsonpath='{.items[*].status.containerStatuses[0].state.waiting.reason}' | grep -qE 'ErrImagePull|ImagePullBackOff'"
