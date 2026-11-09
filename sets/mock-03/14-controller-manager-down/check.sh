check "kube-controller-manager runs (manifest uses controller-manager.conf)" bash -c "
  node_exec $ALT_CP \"grep -q -- '--kubeconfig=/etc/kubernetes/controller-manager.conf' /etc/kubernetes/manifests/kube-controller-manager.yaml && crictl ps --name kube-controller-manager --state running -q | grep -q .\""
check "deployment invoicer has 2 ready pods" deploy_ready alt invoicer billing-ops 2
check "deployment invoicer unchanged" bash -c "[ \"\$(kubectl --context alt -n billing-ops get deploy invoicer -o jsonpath='{.spec.replicas} {.spec.template.spec.containers[0].image}')\" = \"2 $IMG_NGINX\" ]"
check "broken manifest named" bash -c "file_eq '$ANSWERS/broken-manifest.txt' kube-controller-manager.yaml || file_eq '$ANSWERS/broken-manifest.txt' /etc/kubernetes/manifests/kube-controller-manager.yaml"
