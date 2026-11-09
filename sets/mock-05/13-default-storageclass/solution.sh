kubectl --context main annotate sc standard storageclass.kubernetes.io/is-default-class=false --overwrite >/dev/null
apply main <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-retain
  annotations: {storageclass.kubernetes.io/is-default-class: "true"}
provisioner: rancher.io/local-path
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: scratch, namespace: lab-sc}
spec:
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 200Mi}}
---
apiVersion: v1
kind: Pod
metadata: {name: scratch-writer, namespace: lab-sc}
spec:
  containers:
  - name: writer
    image: $IMG_BUSYBOX
    command: ["sh", "-c", "date > /scratch/started && sleep infinity"]
    volumeMounts: [{name: scratch, mountPath: /scratch}]
  volumes: [{name: scratch, persistentVolumeClaim: {claimName: scratch}}]
YAML
wait_for 120 pod_ready main scratch-writer lab-sc
