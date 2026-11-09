kubectl --context alt -n kube-system get cm kube-proxy -o yaml | sed 's/^    mode: "iptabels"/    mode: "iptables"/' | kubectl --context alt apply -f - >/dev/null 2>&1
kubectl --context alt -n kube-system delete pod -l k8s-app=kube-proxy >/dev/null
wait_for 120 bash -c "[ \"\$(kubectl --context alt -n kube-system get pods -l k8s-app=kube-proxy --field-selector spec.nodeName=$ALT_CP -o jsonpath='{.items[*].status.containerStatuses[0].ready}')\" = true ]"
wait_for 60 bash -c "ip=\$(kubectl --context alt -n api get svc quotes -o jsonpath='{.spec.clusterIP}'); node_exec $ALT_CP \"curl -s -m 4 http://\$ip:8080/\" | grep -q 'it works'"
