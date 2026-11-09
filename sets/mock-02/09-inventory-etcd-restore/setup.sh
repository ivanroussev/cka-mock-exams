ns alt inventory
for cm in sku-catalog price-rules warehouse-map; do
  kubectl --context alt -n inventory create configmap $cm --from-literal=owner=inventory-team --from-literal=name=$cm >/dev/null
done
node_exec "$ALT_CP" "rm -rf /opt/etcd-backup /var/lib/etcd-restored && mkdir -p /opt/etcd-backup && etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /opt/etcd-backup/inventory.db" >/dev/null 2>&1
# The "accident", after the backup:
kubectl --context alt -n inventory delete configmap price-rules warehouse-map >/dev/null
kubectl --context alt -n inventory create configmap created-after-backup --from-literal=note="must disappear after the restore" >/dev/null
