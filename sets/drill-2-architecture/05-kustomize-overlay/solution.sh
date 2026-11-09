O="$FILES/kustomize/overlays/prod"
cat > "$O/kustomization.yaml" <<YAML
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
namespace: kz-prod
namePrefix: prod-
labels:
- pairs:
    env: prod
  includeTemplates: true
images:
- name: nginx
  newTag: 1.28-alpine
replicas:
- name: api
  count: 3
configMapGenerator:
- name: api-config
  literals:
  - LOG_LEVEL=warn
  - MODE=production
YAML
kc main apply -k "$O"
kc main -n kz-prod rollout status deploy/prod-api --timeout=180s
