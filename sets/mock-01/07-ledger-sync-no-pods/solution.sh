node_exec "$ALT_CP" "sed -i 's#--kubeconfig=/etc/kubernetes/controller-manager.cnf#--kubeconfig=/etc/kubernetes/controller-manager.conf#' /etc/kubernetes/manifests/kube-controller-manager.yaml"
wait_for 240 deploy_ready alt ledger-sync ops 2
