apply main <<YAML
apiVersion: v1
kind: Service
metadata: {name: kv, namespace: kv}
spec:
  clusterIP: None
  selector: {app: kv}
  ports: [{port: 6379}]
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
      containers: [{name: redis, image: $IMG_REDIS, ports: [{containerPort: 6379}]}]
YAML
kubectl --context main -n kv create poddisruptionbudget kv-pdb --selector=app=kv --min-available=2
echo kv-1.kv.kv.svc.cluster.local > "$ANSWERS/kv-replica.txt"
kubectl --context main -n kv rollout status sts/kv --timeout=180s
wait_for 60 bash -c '[ "$(kubectl --context main -n kv get pdb kv-pdb -o jsonpath="{.status.expectedPods}")" = 3 ]'
