join_ok() {
  local f tok hash want
  f="$(node_exec "$MAIN_CP" "cat /root/join-worker.sh" 2>/dev/null)" || return 1
  printf '%s' "$f" | grep -q 'kubeadm join .*:6443' || return 1
  tok="$(printf '%s' "$f" | grep -o -- '--token [a-z0-9.]*' | awk '{print $2}')"; [ -n "$tok" ] || return 1
  hash="$(printf '%s' "$f" | grep -o -- 'sha256:[a-f0-9]*' | head -1)"
  want="sha256:$(node_exec "$MAIN_CP" "cat /etc/kubernetes/pki/ca.crt" | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | awk '{print $NF}')"
  [ "$hash" = "$want" ] || return 1
  # the token exists and expires in 1h50m–2h05m from now
  local exp now; exp="$(kubectl --context main -n kube-system get secret "bootstrap-token-${tok%%.*}" -o jsonpath='{.data.expiration}' 2>/dev/null | base64 -d)"
  [ -n "$exp" ] || return 1
  exp="$(date -j -u -f '%Y-%m-%dT%H:%M:%SZ' "$exp" +%s 2>/dev/null || date -u -d "$exp" +%s)"; now="$(date +%s)"
  [ $((exp - now)) -gt 6000 ] && [ $((exp - now)) -lt 7500 ]
}
check "sysctl file on worker2 sets ip_forward and bridge-nf-call-iptables, and ip_forward is active" node_exec "$MAIN_W2" "f=/etc/sysctl.d/k8s.conf; grep -Eq '^net.ipv4.ip_forward *= *1' \$f && grep -Eq '^net.bridge.bridge-nf-call-iptables *= *1' \$f && [ \$(sysctl -n net.ipv4.ip_forward) = 1 ]"
check "modules-load file on worker2 lists overlay and br_netfilter" node_exec "$MAIN_W2" "grep -qx overlay /etc/modules-load.d/k8s.conf && grep -qx br_netfilter /etc/modules-load.d/k8s.conf"
check "/root/join-worker.sh: a valid join command with a new 2h token and the CA hash" join_ok
check "service-cidr.txt matches the cluster's service subnet" bash -c "want=\$(kubectl --context main -n kube-system get cm kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | awk '/serviceSubnet:/{print \$2}'); [ -n \"\$want\" ] && file_eq '$ANSWERS/service-cidr.txt' \"\$want\""
