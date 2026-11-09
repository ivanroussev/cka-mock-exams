check "both nodes of cluster bare are Ready" bash -c "node_ready bare $BARE_CP && node_ready bare $BARE_W1"
check "calico-node runs on both nodes" bash -c "[ \"\$(kubectl --context bare -n kube-system get ds calico-node -o jsonpath='{.status.numberReady}')\" = 2 ]"
check "Calico's IP pool matches the cluster's pod CIDR 192.168.0.0/16" bash -c "[ \"\$(kubectl --context bare get ippools.crd.projectcalico.org -o jsonpath='{.items[*].spec.cidr}')\" = 192.168.0.0/16 ]"
check "pod probe-b gets an IP from 192.168.0.0/16 and is reachable from another pod" bash -c "ip=\$(kubectl --context bare get pod probe-b -o jsonpath='{.status.podIP}'); case \"\$ip\" in 192.168.*) ;; *) exit 1;; esac; http_ok bare default http://\$ip/ 'Welcome to nginx'"
