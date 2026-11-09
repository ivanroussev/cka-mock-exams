```bash
kubectl config use-context main
helm show values {{FILES}}/charts/kvcache-operator          # replicaCount, logLevel, watchNamespace
helm install kvcache {{FILES}}/charts/kvcache-operator -n cache-system --create-namespace \
  --set replicaCount=2 --set logLevel=debug --set watchNamespace=sessions
helm -n cache-system list
helm -n cache-system get values kvcache
ls {{FILES}}/charts/kvcache-operator/crds/            # Helm installs everything in crds/ before the templates
kubectl get crd | grep cache.example.io
kubectl get crd -o name | grep cache.example.io | cut -d/ -f2 > {{ANSWERS}}/kvcache-crds.txt
kubectl explain kvcache.spec --recursive                # replicas, memory, eviction.policy
```
```yaml
apiVersion: cache.example.io/v1beta1
kind: KVCache
metadata: {name: session-store, namespace: sessions}
spec:
  replicas: 3
  memory: 512Mi
  eviction:
    policy: allkeys-lru
```
**Notes:** CRDs in a chart's `crds/` folder are installed on `helm install` but never upgraded or deleted by Helm, and they don't show in
`helm get manifest`. `kubectl explain` works for custom resources once the CRD has a schema — the quickest way to find nested field names.
