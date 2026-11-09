y="$(cat <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata: {name: kv-local}
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
---
apiVersion: v1
kind: Service
metadata: {name: kv, namespace: kv}
spec:
  clusterIP: None
  selector: {app: kv}
  ports: [{name: redis, port: 6379}]
---
apiVersion: apps/v1
kind: StatefulSet
metadata: {name: kv, namespace: kv}
spec:
  serviceName: kv
  replicas: 3
  selector: {matchLabels: {app: kv}}
  template:
    metadata: {labels: {app: kv}}
    spec:
      containers:
      - name: redis
        image: $IMG_REDIS
        args: ["--dir", "/data"]
        ports: [{containerPort: 6379}]
        volumeMounts: [{name: data, mountPath: /data}]
  volumeClaimTemplates:
  - metadata: {name: data}
    spec:
      storageClassName: kv-local
      accessModes: [ReadWriteOnce]
      resources: {requests: {storage: 256Mi}}
YAML
)"
# retry: the API server of a loaded kind cluster occasionally drops a request
for i in 1 2 3 4 5; do printf '%s\n' "$y" | kubectl --context main apply -f - >/dev/null && break; sleep 10; done
kubectl --context main -n kv rollout status sts/kv --timeout=240s >/dev/null
