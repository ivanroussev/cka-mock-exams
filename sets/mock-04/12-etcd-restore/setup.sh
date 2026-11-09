ns alt platform-config
kubectl --context alt -n platform-config create configmap feature-flags --from-literal=checkout_v2=true --from-literal=dark_mode=false >/dev/null
kubectl --context alt -n platform-config create configmap rate-limits --from-literal=api_rps=250 --from-literal=burst=500 >/dev/null
kubectl --context alt -n platform-config create configmap routing-table --from-literal=eu=fra1 --from-literal=us=iad2 >/dev/null
ETCD_CERTS="--cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key --endpoints=https://127.0.0.1:2379"
node_exec "$ALT_CP" "mkdir -p /var/lib/etcd-backup && etcdctl $ETCD_CERTS snapshot save /var/lib/etcd-backup/pre-migration.db >/dev/null 2>&1"
node_exec "$ALT_CP" "test -s /var/lib/etcd-backup/pre-migration.db"
# The "migration": delete two ConfigMaps and overwrite one.
kubectl --context alt -n platform-config delete configmap feature-flags routing-table >/dev/null
kubectl --context alt -n platform-config create configmap rate-limits --from-literal=api_rps=1 --dry-run=client -o yaml | kubectl --context alt apply -f - >/dev/null 2>&1
