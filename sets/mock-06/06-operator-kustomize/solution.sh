k="$FILES/widget-operator"
sed -i '' 's/verbs: \["get"\]/verbs: ["get", "list", "watch"]/' "$k/components/rbac/clusterrole.yaml" 2>/dev/null \
  || sed -i 's/verbs: \["get"\]/verbs: ["get", "list", "watch"]/' "$k/components/rbac/clusterrole.yaml"
mkdir -p "$k/overlays/prod"
cat > "$k/overlays/prod/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
components:
- ../../components/rbac
labels:
- pairs: {env: prod}
replicas:
- name: widget-operator
  count: 2
YAML
kubectl --context main apply -k "$k/overlays/prod" >/dev/null 2>&1 || { sleep 5; kubectl --context main apply -k "$k/overlays/prod" >/dev/null; }
wait_for 30 bash -c "kubectl --context main get --raw /apis/apps.example.com/v1 >/dev/null"
apply main <<'YAML'
apiVersion: apps.example.com/v1
kind: Widget
metadata: {name: demo, namespace: widget-system}
spec: {size: 3}
YAML
kubectl --context main -n widget-system rollout status deploy/widget-operator --timeout=150s >/dev/null
