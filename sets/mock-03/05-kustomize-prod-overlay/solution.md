```bash
cd {{FILES}}/invoice-api
cat base/kustomization.yaml overlays/staging/kustomization.yaml     # learn the layout
mkdir -p overlays/prod && cd overlays/prod
kubectl create namespace invoice-prod      # or add a Namespace resource to the overlay (done below)
```
`overlays/prod/kustomization.yaml`:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: invoice-prod
resources:
- ../../base
- namespace.yaml          # optional: a Namespace manifest so apply -k creates it
labels:
- pairs: {env: prod}      # (commonLabels also works, but also rewrites selectors)
replicas:
- name: invoice-api
  count: 3
patches:
- path: resources.yaml
configMapGenerator:
- name: invoice-api-config
  behavior: merge         # without this kustomize refuses: the name already exists in the base
  literals: [LOG_LEVEL=warn]
```
`overlays/prod/resources.yaml` (strategic merge patch — containers are merged by `name`):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata: {name: invoice-api}
spec:
  template:
    spec:
      containers:
      - name: api
        resources:
          requests: {cpu: 250m, memory: 128Mi}
          limits: {memory: 256Mi}
```
```bash
kubectl kustomize .            # check the output first
kubectl apply -k .
kubectl -n invoice-prod get deploy,cm
```
**Pitfalls:** a second `configMapGenerator` entry with the same name needs `behavior: merge` (or `replace`, which would drop the other keys).
Kustomize appends a hash to the ConfigMap name and rewrites the Deployment's reference for you. Docs: kubernetes.io → "Declarative Management of Kubernetes Objects Using Kustomize".
