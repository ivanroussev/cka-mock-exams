check "API server of cluster bare answers /readyz" kubectl --context bare get --raw=/readyz --request-timeout=5s
check "kube-apiserver mirror pod is Running" field_eq bare "pod/kube-apiserver-$BARE_CP -n kube-system" '{.status.phase}' Running
check "manifest points at etcd on 127.0.0.1:2379" node_file_has "$BARE_CP" /etc/kubernetes/manifests/kube-apiserver.yaml "--etcd-servers=https://127.0.0.1:2379"
check "wrong flag named" bash -c "[ \"\$(tr -d '[:space:]' < '$ANSWERS/apiserver-flag.txt' | sed 's/^-*//; s/=.*//')\" = etcd-servers ]"
