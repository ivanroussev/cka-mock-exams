ETCDCTL="etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key --command-timeout=10s"
rev() { node_exec "$ALT_CP" "etcdutl snapshot status $1 -w json 2>/dev/null" | sed -n 's/.*"revision":\([0-9]*\).*/\1/p'; }
export -f rev
check "etcd-now.db is a valid snapshot taken after the bad change" bash -c "
  now=\$(rev /opt/backups/etcd-now.db) && pre=\$(rev /opt/backups/etcd-pre-change.db) &&
  [ -n \"\$now\" ] && [ -n \"\$pre\" ] && [ \"\$now\" -gt \"\$pre\" ]"
check "etcd static pod uses data directory /var/lib/etcd-restored" bash -c "
  node_exec $ALT_CP \"grep -qE '^ *path: /var/lib/etcd-restored/?\\\$' /etc/kubernetes/manifests/etcd.yaml && test -d /var/lib/etcd-restored/member\" &&
  [ \"\$(kubectl --context alt -n kube-system get pod etcd-$ALT_CP -o jsonpath='{.spec.volumes[?(@.hostPath.path==\"/var/lib/etcd-restored\")].name}')\" != '' ]"
check "etcd holds the restored data (app-settings back, debug-override gone)" bash -c "
  node_exec $ALT_CP \"$ETCDCTL get /registry/configmaps/etcd-drill/app-settings --keys-only | grep -q app-settings &&
    ! $ETCDCTL get /registry/configmaps/etcd-drill/debug-override --keys-only | grep -q debug-override\""
check "the API server serves the restored state and both nodes are Ready" bash -c "
  kubectl --context alt -n etcd-drill get configmap app-settings &&
  ! kubectl --context alt -n etcd-drill get configmap debug-override &&
  node_ready alt $ALT_CP && node_ready alt $ALT_W1"
