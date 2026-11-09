snap_ok()   { node_exec cp1 "etcdutl snapshot status /opt/backup/pre-cleanup.db >/dev/null 2>&1"; }
uses_dir()  { node_exec cp1 "grep -qE 'path: /var/lib/etcd-restore/?\$' /etc/kubernetes/manifests/etcd.yaml && [ -d /var/lib/etcd-restore/member ]"; }
healthy()   { vm_kubectl get --raw /readyz >/dev/null &&
              node_exec cp1 "etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt \
                --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key endpoint health >/dev/null 2>&1"; }
ns_back()   { local u; u="$(cat "$STATE/mock06-payments-uid" 2>/dev/null)"
              [ -n "$u" ] && [ "$(vm_kubectl get ns payments -o jsonpath='{.metadata.uid}/{.status.phase}')" = "$u/Active" ]; }
objs_back() { local b; b="$(cat "$STATE/mock06-ledger-batch" 2>/dev/null)"
              [ -n "$b" ] && [ "$(vm_kubectl -n payments get cm ledger -o jsonpath='{.data.batch}')" = "$b" ] &&
              vm_kubectl -n payments get deploy ledger-api >/dev/null; }

check "/opt/backup/pre-cleanup.db is a valid etcd snapshot" snap_ok
check "etcd runs from the restored data directory /var/lib/etcd-restore" uses_dir
check "API server and etcd are healthy" healthy
check "namespace payments is the restored original (same UID)" ns_back
check "ConfigMap ledger and Deployment ledger-api are back" objs_back
