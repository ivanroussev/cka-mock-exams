check "both nodes of bare are Ready" bash -c "node_ready bare $BARE_CP && node_ready bare $BARE_W1"
check "calico-node runs on both nodes (v3.32.3)" bash -c "
  [ \"\$(kubectl --context bare -n kube-system get ds calico-node -o jsonpath='{.status.numberReady}')\" = 2 ] &&
  kubectl --context bare -n kube-system get ds calico-node -o jsonpath='{.spec.template.spec.containers[0].image}' | grep -q ':v3.32.3\$'"
check "pod probe is Running with an IP from 192.168.0.0/16" bash -c "
  pod_ready bare probe net-check &&
  kubectl --context bare -n net-check get pod probe -o jsonpath='{.status.podIP}' | grep -q '^192\.168\.'"
check "cni-config.txt names Calico's CNI config file" bash -c "
  f=\$(tr -d '[:space:]' < '$ANSWERS/cni-config.txt') && [ -n \"\$f\" ] && case \"\$f\" in */*) exit 1;; *.conflist|*.conf) ;; *) exit 1;; esac &&
  node_exec $BARE_W1 \"test -f /etc/cni/net.d/\$f && grep -q calico /etc/cni/net.d/\$f\""
