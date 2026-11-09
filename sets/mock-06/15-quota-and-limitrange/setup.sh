ns main team-red
apply main <<YAML
apiVersion: v1
kind: ResourceQuota
metadata: {name: team-red-quota, namespace: team-red}
spec:
  hard:
    pods: "5"
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.memory: 2Gi
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: worker, namespace: team-red}
spec:
  replicas: 4
  selector: {matchLabels: {app: worker}}
  template:
    metadata: {labels: {app: worker}}
    spec:
      containers:
      - name: worker
        image: $IMG_BUSYBOX
        command: ["sleep", "infinity"]
YAML
