# Runs on cp1; prints nothing, exit code is the result.
tok='K="kubectl --kubeconfig /etc/kubernetes/admin.conf"
t=$(grep -o -- "--token[ =][^ ]*" /root/join-command.txt | head -1 | sed "s/--token[ =]//")
id=${t%%.*}; sec=${t#*.}
[ -n "$id" ] && [ "$($K -n kube-system get secret bootstrap-token-$id -o jsonpath="{.data.token-secret}" | base64 -d)" = "$sec" ]'
ttl='K="kubectl --kubeconfig /etc/kubernetes/admin.conf"
t=$(grep -o -- "--token[ =][^ ]*" /root/join-command.txt | head -1 | sed "s/--token[ =]//")
exp=$($K -n kube-system get secret bootstrap-token-${t%%.*} -o jsonpath="{.data.expiration}" | base64 -d)
d=$(( $(date -d "$exp" +%s) - $(date +%s) )); [ "$d" -gt 1800 ] && [ "$d" -le 7500 ]'
hash='want=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed "s/^.* //")
grep -q -- "--discovery-token-ca-cert-hash[ =]sha256:$want" /root/join-command.txt'

check "/root/join-command.txt holds a kubeadm join command" node_exec cp1 \
  "grep -qE '^[[:space:]]*(sudo +)?kubeadm join [^ ]+:6443' /root/join-command.txt"
check "it uses an existing bootstrap token" node_exec cp1 "$tok"
check "that token expires in about 2 hours" node_exec cp1 "$ttl"
check "it has the correct CA certificate hash" node_exec cp1 "$hash"
