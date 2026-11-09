ns main uploads
apply main <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: uploads-data, namespace: uploads}
spec:
  storageClassName: standard
  accessModes: [ReadWriteMany]
  resources: {requests: {storage: 2Gi}}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: uploader, namespace: uploads}
spec:
  replicas: 1
  selector: {matchLabels: {app: uploader}}
  template:
    metadata: {labels: {app: uploader}}
    spec:
      containers:
      - name: uploader
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "date >> /data/started.log; sleep infinity"]
        volumeMounts: [{name: data, mountPath: /data}]
      volumes:
      - name: data
        persistentVolumeClaim: {claimName: uploads-data}
YAML
wait_for 60 bash -c "kubectl --context main -n uploads get events --field-selector involvedObject.name=uploads-data 2>/dev/null | grep -q ProvisioningFailed"
