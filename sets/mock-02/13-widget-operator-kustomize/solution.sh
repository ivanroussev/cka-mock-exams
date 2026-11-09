O="$FILES/widget-operator/overlays/prod"
mkdir -p "$O"
cat > "$O/kustomization.yaml" <<'YAML'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: widgets-prod
resources:
- ../../base
images:
- name: nginx
  newTag: 1.28-alpine
replicas:
- name: widget-controller
  count: 2
labels:
- pairs: {env: prod}
YAML
kubectl --context main create namespace widgets-prod
kubectl --context main apply -k "$O"
kubectl --context main wait crd/widgets.acme.example.com --for=condition=Established --timeout=60s
apply main <<'YAML'
apiVersion: acme.example.com/v1alpha1
kind: Widget
metadata: {name: blue, namespace: widgets-prod}
spec: {color: blue, size: 3}
YAML
kubectl --context main -n widgets-prod rollout status deploy/widget-controller --timeout=120s
