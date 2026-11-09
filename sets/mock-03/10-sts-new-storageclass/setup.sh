ns main consensus
apply main <<YAML
apiVersion: v1
kind: Service
metadata: {name: quorum, namespace: consensus}
spec:
  clusterIP: None
  selector: {app: quorum}
  ports: [{port: 80}]
---
apiVersion: apps/v1
kind: StatefulSet
metadata: {name: quorum, namespace: consensus}
spec:
  serviceName: quorum
  replicas: 3
  selector: {matchLabels: {app: quorum}}
  template:
    metadata: {labels: {app: quorum}}
    spec:
      containers:
      - name: node
        image: $IMG_NGINX
        volumeMounts: [{name: data, mountPath: /var/lib/quorum}]
  volumeClaimTemplates:
  - metadata: {name: data}
    spec:
      storageClassName: standard
      accessModes: [ReadWriteOnce]
      resources: {requests: {storage: 1Gi}}
YAML
kubectl --context main -n consensus rollout status sts/quorum --timeout=240s >/dev/null
