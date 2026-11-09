Docs: search **"Kustomize"** → *Declarative Management of Kubernetes Objects Using Kustomize* (has every field below).

`{{FILES}}/kustomize/overlays/prod/kustomization.yaml`:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
namespace: kz-prod
namePrefix: prod-
labels:
- pairs:
    env: prod
  includeTemplates: true      # also label the pod template
images:
- name: nginx                 # matches the image *name* in the base
  newTag: 1.28-alpine
replicas:                     # or a patch that sets spec.replicas: 3
- name: api                   # the name *before* the prefix
  count: 3
configMapGenerator:
- name: api-config
  literals:
  - LOG_LEVEL=warn
  - MODE=production
```
```bash
kubectl kustomize {{FILES}}/kustomize/overlays/prod      # preview first
kubectl config use-context main
kubectl apply -k {{FILES}}/kustomize/overlays/prod
kubectl -n kz-prod get deploy,svc,cm,pods --show-labels
```
**What to notice:** the generator creates `prod-api-config-<hash>` and Kustomize rewrites the Deployment's `configMapRef` to match,
so a config change rolls the pods. `labels` without `includeTemplates: true` labels only the objects, not the pods
(`commonLabels` labels everything, selectors included, but is deprecated). `images`/`replicas` refer to names as they are in the base.
