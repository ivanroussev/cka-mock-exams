node_exec "$ALT_CP" "sed -i 's#/etc/kubernetes/controller-manager.kubeconfig#/etc/kubernetes/controller-manager.conf#' /etc/kubernetes/manifests/kube-controller-manager.yaml"
wait_for 180 deploy_ready alt reports ops 2
wait_for 60 bash -c "[ \"\$(kubectl --context alt -n kube-system get pod kube-controller-manager-$ALT_CP -o jsonpath='{.status.containerStatuses[0].ready}')\" = true ]"
