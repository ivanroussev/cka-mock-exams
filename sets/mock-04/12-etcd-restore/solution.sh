# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
C="--cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key --endpoints=https://127.0.0.1:2379"
node_exec "$ALT_CP" "etcdctl $C snapshot save /var/lib/etcd-backup/post-migration.db"
node_exec "$ALT_CP" "etcdutl snapshot restore /var/lib/etcd-backup/pre-migration.db --data-dir /var/lib/etcd-restored"
node_exec "$ALT_CP" "sed -i 's#^      path: /var/lib/etcd\$#      path: /var/lib/etcd-restored#' /etc/kubernetes/manifests/etcd.yaml"
# etcd restarts with the restored data; restart the other control-plane components so their caches start fresh.
sleep 20
wait_for 180 bash -c "[ \"\$(kubectl --context alt get --raw=/readyz 2>/dev/null)\" = ok ]"
node_exec "$ALT_CP" "for c in kube-apiserver kube-controller-manager kube-scheduler; do crictl ps --name \$c -q | xargs -r crictl stop >/dev/null; done; systemctl restart kubelet"
# Kubelets keep watches with resource versions from *after* the snapshot; restart them on every node.
node_exec "$ALT_W1" "systemctl restart kubelet"
sleep 10
wait_for 180 bash -c "[ \"\$(kubectl --context alt get --raw=/readyz 2>/dev/null)\" = ok ] && kubectl --context alt -n platform-config get cm feature-flags"
wait_for 120 bash -c "[ \"\$(kubectl --context alt -n kube-system get pod etcd-$ALT_CP -o jsonpath='{.status.containerStatuses[0].ready}')\" = true ]"
# Workloads from before the restore converge again.
wait_for 180 bash -c "! kubectl --context alt get deploy -A -o jsonpath='{range .items[*]}{.status.readyReplicas}/{.spec.replicas}{\"\n\"}{end}' | grep -v '^\([0-9]*\)/\1\$' | grep -q ."
