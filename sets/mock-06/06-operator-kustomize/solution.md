```bash
cd {{FILES}}/widget-operator && mkdir -p overlays/prod
cat <<'YAML' > overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
components:                 # components are listed separately from resources
- ../../components/rbac
labels:
- pairs: {env: prod}        # (commonLabels: {env: prod} also works, but also rewrites selectors)
replicas:
- name: widget-operator
  count: 2
YAML
kubectl kustomize overlays/prod | less          # always render first
kubectl apply -k overlays/prod
kubectl -n widget-system logs deploy/widget-operator --tail=3      # list widgets: HTTP 403
vim components/rbac/clusterrole.yaml            # verbs: ["get", "list", "watch"]
kubectl apply -k overlays/prod
kubectl auth can-i watch widgets.apps.example.com -A --as system:serviceaccount:widget-system:widget-operator   # yes
cat <<'YAML' | kubectl apply -f -
apiVersion: apps.example.com/v1
kind: Widget
metadata: {name: demo, namespace: widget-system}
spec: {size: 3}
YAML
kubectl -n widget-system get deploy,wdg
```
Docs: kubernetes.io → *Declarative Management of Kubernetes Objects Using Kustomize* (components, labels, replicas).
**Pitfalls:** a component must be referenced under `components:`, not `resources:` (kustomize errors on `kind: Component` there).
If the first `apply -k` complains that kind `Widget` is unknown, that's only the CR — the CRD has to exist first. Fixing the
ClusterRole with `kubectl edit` works until the next `apply -k` reverts it; that's why the fix belongs in the files.
