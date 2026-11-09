```bash
kubectl config use-context main
mkdir -p {{FILES}}/widget-operator/overlays/prod && cd {{FILES}}/widget-operator/overlays/prod
vim kustomization.yaml
```
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: widgets-prod
resources:
- ../../base
images:
- name: nginx              # matches the image name in the base, without tag
  newTag: 1.28-alpine
replicas:
- name: widget-controller
  count: 2
labels:                    # (or the older commonLabels: {env: prod})
- pairs:
    env: prod
```
```bash
kubectl kustomize .                       # check the output first
kubectl create namespace widgets-prod
kubectl apply -k .
kubectl explain widget.spec --api-version=acme.example.com/v1alpha1
cat > blue.yaml <<'EOF'
apiVersion: acme.example.com/v1alpha1
kind: Widget
metadata: {name: blue, namespace: widgets-prod}
spec:
  color: blue
  size: 3
EOF
kubectl apply -f blue.yaml
```
**Notes:** `namespace:` in a kustomization sets the namespace of namespaced resources but doesn't create the Namespace
(create it, or add a `namespace.yaml` to the overlay's resources). Cluster-scoped objects like the CRD stay cluster-scoped.
`kubectl apply -k` uses kubectl's built-in kustomize; no separate binary is needed.
