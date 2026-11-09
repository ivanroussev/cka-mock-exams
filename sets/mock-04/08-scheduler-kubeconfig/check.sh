check "kube-scheduler runs with its kubeconfig volume pointing at scheduler.conf" bash -c "
  node_exec $ALT_CP \"grep -qx '      path: /etc/kubernetes/scheduler.conf' /etc/kubernetes/manifests/kube-scheduler.yaml && ! grep -q scheduler-v2 /etc/kubernetes/manifests/kube-scheduler.yaml\" &&
  [ \"\$(kubectl --context alt -n kube-system get pod kube-scheduler-$ALT_CP -o jsonpath='{.status.containerStatuses[0].ready}')\" = true ]"
check "ledger-sync has 2 running pods" deploy_ready alt ledger-sync sync 2
check "deployment unchanged" bash -c "[ \"\$(kubectl --context alt -n sync get deploy ledger-sync -o jsonpath='{.spec.replicas} {.spec.template.spec.containers[0].image}')\" = \"2 $IMG_BUSYBOX\" ]"
check "misconfigured volume named" file_eq "$ANSWERS/scheduler-volume.txt" kubeconfig
