check "kube-controller-manager is running" bash -c "
  [ \"\$(kubectl --context alt -n kube-system get pod kube-controller-manager-$ALT_CP -o jsonpath='{.status.containerStatuses[0].ready}')\" = true ] &&
  ! kubectl --context alt -n kube-system get pod kube-controller-manager-$ALT_CP -o jsonpath='{.status.containerStatuses[0].state}' | grep -q waiting"
check "controller-manager manifest uses /etc/kubernetes/controller-manager.conf" node_exec "$ALT_CP" "grep -q -- '--kubeconfig=/etc/kubernetes/controller-manager.conf' /etc/kubernetes/manifests/kube-controller-manager.yaml"
check "ledger-sync has 2 ready pods" deploy_ready alt ledger-sync ops 2
check "Deployment ledger-sync was not changed" bash -c "[ \"\$(kubectl --context alt -n ops get deploy ledger-sync -o jsonpath='{.metadata.generation}/{.spec.replicas}')\" = 1/2 ]"
