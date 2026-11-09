helm rollback inventory 1 --kube-context main -n inv --wait --timeout 3m >/dev/null
helm upgrade inventory "$FILES/inventory" --kube-context main -n inv --set image.tag=1.28-alpine --set replicaCount=3 --wait --timeout 3m >/dev/null
kubectl --context main -n inv rollout status deploy/inventory --timeout=120s >/dev/null
