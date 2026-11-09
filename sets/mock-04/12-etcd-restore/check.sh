check "post-migration snapshot saved and valid" node_exec "$ALT_CP" "etcdutl snapshot status /var/lib/etcd-backup/post-migration.db >/dev/null 2>&1 && [ /var/lib/etcd-backup/post-migration.db -nt /var/lib/etcd-backup/pre-migration.db ]"
check "etcd runs from /var/lib/etcd-restored" bash -c "
  node_exec $ALT_CP \"test -d /var/lib/etcd-restored/member && grep -q 'path: /var/lib/etcd-restored' /etc/kubernetes/manifests/etcd.yaml\" &&
  [ \"\$(kubectl --context alt -n kube-system get pod etcd-$ALT_CP -o jsonpath='{.status.containerStatuses[0].ready}')\" = true ]"
check "deleted ConfigMaps are back" bash -c "
  [ \"\$(kubectl --context alt -n platform-config get cm feature-flags -o jsonpath='{.data.checkout_v2}') \$(kubectl --context alt -n platform-config get cm routing-table -o jsonpath='{.data.eu}')\" = 'true fra1' ]"
check "rate-limits has its pre-migration values and the API server is healthy" bash -c "
  [ \"\$(kubectl --context alt -n platform-config get cm rate-limits -o jsonpath='{.data.api_rps}/{.data.burst}')\" = 250/500 ] &&
  [ \"\$(kubectl --context alt get --raw=/readyz)\" = ok ]"
