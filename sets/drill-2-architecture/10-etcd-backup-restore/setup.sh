ETCDCTL="etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key"
ns alt etcd-drill
kc alt -n etcd-drill create configmap app-settings --from-literal=mode=safe >/dev/null
node_exec "$ALT_CP" "mkdir -p /opt/backups && rm -f /opt/backups/*.db && $ETCDCTL snapshot save /opt/backups/etcd-pre-change.db >/dev/null 2>&1"
# The "bad change", made after the snapshot.
kc alt -n etcd-drill delete configmap app-settings >/dev/null
kc alt -n etcd-drill create configmap debug-override --from-literal=mode=debug >/dev/null
