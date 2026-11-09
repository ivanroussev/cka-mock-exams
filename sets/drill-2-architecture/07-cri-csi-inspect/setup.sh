apply main <<'YAML'
apiVersion: storage.k8s.io/v1
kind: CSIDriver
metadata: {name: files.csi.acme.io}
spec:
  attachRequired: false
  podInfoOnMount: true
  volumeLifecycleModes: ["Persistent"]
---
apiVersion: storage.k8s.io/v1
kind: CSIDriver
metadata: {name: blocks.csi.acme.io}
spec:
  attachRequired: true
  podInfoOnMount: false
  volumeLifecycleModes: ["Persistent"]
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata: {name: archive}
provisioner: files.csi.acme.io
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata: {name: bulk}
provisioner: blocks.csi.acme.io
reclaimPolicy: Delete
volumeBindingMode: Immediate
YAML
