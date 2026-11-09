ns main reports
wait_for 60 kubectl --context main -n reports get serviceaccount default   # a brand-new namespace gets its SA a moment later; Pods are rejected until then
apply main <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata: {name: resizable}
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: report-data, namespace: reports}
spec:
  storageClassName: resizable
  accessModes: [ReadWriteOnce]
  resources: {requests: {storage: 1Gi}}
---
apiVersion: v1
kind: Pod
metadata: {name: report-writer, namespace: reports}
spec:
  containers:
  - name: app
    image: $IMG_BUSYBOX
    command: ["sleep", "infinity"]
    volumeMounts: [{name: data, mountPath: /data}]
  volumes: [{name: data, persistentVolumeClaim: {claimName: report-data}}]
YAML
wait_for 120 field_eq main "pvc/report-data -n reports" '{.status.phase}' Bound
kubectl --context main annotate ns reports cka/pvc-uid="$(kubectl --context main -n reports get pvc report-data -o jsonpath='{.metadata.uid}')" --overwrite >/dev/null
