ETCDCTL="etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key"
# 1. Fresh backup
node_exec "$ALT_CP" "$ETCDCTL snapshot save /opt/backups/etcd-now.db"
# 2. Stop the API server, restore into a new dir, point etcd at it, start the API server again.
node_exec "$ALT_CP" "mv /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/kube-apiserver.yaml.stopped"
wait_for 90 node_exec "$ALT_CP" "! crictl ps --name kube-apiserver -q | grep -q ."
node_exec "$ALT_CP" "etcdutl snapshot restore /opt/backups/etcd-pre-change.db --data-dir /var/lib/etcd-restored"
node_exec "$ALT_CP" "sed -i 's#^\( *\)path: /var/lib/etcd\$#\1path: /var/lib/etcd-restored#' /etc/kubernetes/manifests/etcd.yaml"
# Wait for kubelet to restart etcd on the new directory.
wait_for 300 node_exec "$ALT_CP" "crictl inspect \$(crictl ps --name '^etcd\$' -q | head -1) 2>/dev/null | grep -q /var/lib/etcd-restored && $ETCDCTL endpoint health"
node_exec "$ALT_CP" "mv /etc/kubernetes/kube-apiserver.yaml.stopped /etc/kubernetes/manifests/kube-apiserver.yaml"
wait_api alt 300
wait_for 300 bash -c "node_ready alt $ALT_CP && node_ready alt $ALT_W1 && kubectl --context alt -n etcd-drill get configmap app-settings"
# Restart controller-manager and scheduler so they drop state that is newer than the backup.
node_exec "$ALT_CP" "crictl stop \$(crictl ps --name 'kube-controller-manager|kube-scheduler' -q)" >/dev/null 2>&1 || true
wait_for 180 bash -c "[ \"\$(kubectl --context alt -n kube-system get pod -l component=kube-controller-manager -o jsonpath='{.items[0].status.conditions[?(@.type==\"Ready\")].status}')\" = True ]"
# The mirror pod in the API reflects the new manifest a little later.
wait_for 180 bash -c "[ -n \"\$(kubectl --context alt -n kube-system get pod etcd-$ALT_CP -o jsonpath='{.spec.volumes[?(@.hostPath.path==\"/var/lib/etcd-restored\")].name}')\" ]"
