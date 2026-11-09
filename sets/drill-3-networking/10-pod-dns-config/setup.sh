ns main dns-lab
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: records, namespace: dns-lab}
spec:
  replicas: 1
  selector: {matchLabels: {app: records}}
  template:
    metadata: {labels: {app: records}}
    spec:
      containers: [{name: nginx, image: $IMG_NGINX, ports: [{containerPort: 80}]}]
---
apiVersion: v1
kind: Service
metadata: {name: records, namespace: dns-lab}
spec:
  selector: {app: records}
  ports: [{port: 80, targetPort: 80}]
---
apiVersion: v1
kind: Pod
metadata: {name: cache, namespace: dns-lab, labels: {app: cache}}
spec:
  containers: [{name: redis, image: $IMG_REDIS, ports: [{containerPort: 6379}]}]
---
apiVersion: v1
kind: Pod
metadata: {name: lookup, namespace: dns-lab, labels: {app: lookup}}
spec:
  dnsPolicy: None
  dnsConfig:
    nameservers: [192.0.2.53]
    searches: [corp.invalid]
  containers:
  - name: shell
    image: $IMG_BUSYBOX
    command: ["sleep", "86400"]
YAML
kubectl --context main -n dns-lab wait --for=condition=Ready pod/cache pod/lookup --timeout=120s >/dev/null
kubectl --context main -n dns-lab rollout status deploy/records --timeout=120s >/dev/null
