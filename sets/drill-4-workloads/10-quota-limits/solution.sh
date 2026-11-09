apply main <<'YAML'
apiVersion: v1
kind: LimitRange
metadata: {name: container-defaults, namespace: team-a}
spec:
  limits:
  - type: Container
    defaultRequest: {cpu: 100m, memory: 64Mi}
    default: {cpu: 200m, memory: 128Mi}
YAML
kubectl --context main -n team-a create quota team-a-quota --hard=pods=3,requests.cpu=1,limits.memory=1Gi
kubectl --context main create priorityclass team-a-high --value=100000 --description="team-a important workloads"
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: worker, namespace: team-a, labels: {app: worker}}
spec:
  replicas: 4
  selector: {matchLabels: {app: worker}}
  template:
    metadata: {labels: {app: worker}}
    spec:
      priorityClassName: team-a-high
      containers: [{name: nginx, image: $IMG_NGINX}]
YAML
wait_for 120 bash -c '[ "$(kubectl --context main -n team-a get deploy worker -o jsonpath="{.status.readyReplicas}")" = 3 ]'
wait_for 60 bash -c 'kubectl --context main -n team-a get events --field-selector reason=FailedCreate -o jsonpath="{.items[*].message}" | grep -q "exceeded quota"'
kubectl --context main -n team-a get events --field-selector reason=FailedCreate -o jsonpath='{range .items[*]}{.message}{"\n"}{end}' \
  | grep 'exceeded quota' | tail -1 > "$ANSWERS/quota-error.txt"
