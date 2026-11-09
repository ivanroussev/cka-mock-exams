M=/etc/kubernetes/manifests/kube-apiserver.yaml
node_exec "$BARE_CP" "sed 's#--etcd-servers=https://127.0.0.1:2397#--etcd-servers=https://127.0.0.1:2379#' $M > /root/.kas.yaml && cat /root/.kas.yaml > $M && rm /root/.kas.yaml"
echo "--etcd-servers" > "$ANSWERS/apiserver-flag.txt"
wait_api bare 240
wait_for 120 field_eq bare "pod/kube-apiserver-$BARE_CP -n kube-system" '{.status.phase}' Running
