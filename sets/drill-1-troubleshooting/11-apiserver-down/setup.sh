M=/etc/kubernetes/manifests/kube-apiserver.yaml
node_exec "$BARE_CP" "sed 's#--etcd-servers=https://127.0.0.1:2379#--etcd-servers=https://127.0.0.1:2397#' $M > /root/.kas.yaml && cat /root/.kas.yaml > $M && rm /root/.kas.yaml"
sleep 10
wait_for 150 bash -c "! kubectl --context bare get --raw=/readyz --request-timeout=3s"
