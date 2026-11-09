check "snapshot /opt/etcd-backup/pre-upgrade.db is a valid etcd snapshot" node_exec "$ALT_CP" "etcdutl snapshot status /opt/etcd-backup/pre-upgrade.db"
check "snapshot revision written" bash -c "rev=\$(node_exec $ALT_CP 'etcdutl snapshot status /opt/etcd-backup/pre-upgrade.db -w json' | sed -n 's/.*\"revision\":\([0-9]*\).*/\1/p') && [ -n \"\$rev\" ] && file_eq '$ANSWERS/etcd-snapshot-revision.txt' \"\$rev\""
check "apiserver certificate expiry date written" bash -c "
  d=\$(node_exec $ALT_CP 'cat /etc/kubernetes/pki/apiserver.crt' | openssl x509 -noout -enddate | sed 's/notAfter=//') &&
  set -- \$d && grep -Eiq \"\$1 +0?\$2,? +(\$4|[0-9:]+ +\$4)\" '$ANSWERS/apiserver-cert-expiry.txt'"
