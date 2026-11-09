kubectl --context main -n billing-app create cm billing-config --from-file="$FILES/billing.properties" --from-literal=LOG_LEVEL=debug >/dev/null
kubectl --context main -n billing-app create secret generic billing-db --from-literal=DB_USER=billing --from-literal='DB_PASSWORD=S3cure!pass' --dry-run=client -o yaml \
  | awk '{print} /^kind: Secret$/{print "immutable: true"}' | kubectl --context main apply -f - >/dev/null
kubectl --context main -n billing-app patch deploy billing --type=strategic -p '{"spec":{"template":{"spec":{
  "volumes":[{"name":"config","configMap":{"name":"billing-config","items":[{"key":"billing.properties","path":"billing.properties"}]}}],
  "containers":[{"name":"app",
    "env":[{"name":"LOG_LEVEL","valueFrom":{"configMapKeyRef":{"name":"billing-config","key":"LOG_LEVEL"}}}],
    "envFrom":[{"secretRef":{"name":"billing-db"}}],
    "volumeMounts":[{"name":"config","mountPath":"/etc/billing"}]}]}}}}' >/dev/null
kubectl --context main -n billing-app rollout status deploy/billing --timeout=120s >/dev/null
