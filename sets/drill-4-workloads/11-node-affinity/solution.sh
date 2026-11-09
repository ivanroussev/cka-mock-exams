kubectl --context main label node $MAIN_W1 disktype=ssd --overwrite
kubectl --context main label node $MAIN_W2 disktype=hdd --overwrite
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: ssd-cache, namespace: placement}
spec:
  replicas: 2
  selector: {matchLabels: {app: ssd-cache}}
  template:
    metadata: {labels: {app: ssd-cache}}
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions: [{key: disktype, operator: In, values: [ssd]}]
      containers: [{name: redis, image: $IMG_REDIS}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: spread-web, namespace: placement}
spec:
  replicas: 4
  selector: {matchLabels: {app: spread-web}}
  template:
    metadata: {labels: {app: spread-web}}
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions: [{key: disktype, operator: Exists}]
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 50
            preference:
              matchExpressions: [{key: disktype, operator: In, values: [hdd]}]
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: DoNotSchedule
        labelSelector: {matchLabels: {app: spread-web}}
      containers: [{name: nginx, image: $IMG_NGINX}]
---
apiVersion: v1
kind: Pod
metadata: {name: pinned, namespace: placement}
spec:
  nodeName: $MAIN_CP
  containers: [{name: pinned, image: $IMG_BUSYBOX, command: ["sleep", "3600"]}]
YAML
kubectl --context main -n placement rollout status deploy/ssd-cache --timeout=120s
kubectl --context main -n placement rollout status deploy/spread-web --timeout=120s
kubectl --context main -n placement wait --for=condition=Ready pod/pinned --timeout=120s
