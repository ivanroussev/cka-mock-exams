apply main <<'YAML'
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata: {name: retain-local}
provisioner: rancher.io/local-path
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: journal-data, namespace: notes}
spec:
  storageClassName: retain-local
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 256Mi}}
YAML
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: journal, namespace: notes}
spec:
  replicas: 1
  selector: {matchLabels: {app: journal}}
  template:
    metadata: {labels: {app: journal}}
    spec:
      containers:
      - name: nginx
        image: $IMG_NGINX
        volumeMounts: [{name: data, mountPath: /usr/share/nginx/html}]
      volumes:
      - name: data
        persistentVolumeClaim: {claimName: journal-data}
YAML
kubectl --context main -n notes rollout status deploy/journal --timeout=180s
kubectl --context main -n notes exec deploy/journal -- sh -c 'echo "journal v1" > /usr/share/nginx/html/index.html'
