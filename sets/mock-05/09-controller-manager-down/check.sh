kcm_ok() {
  local p="kube-controller-manager-$ALT_CP"
  [ "$(jsonpath alt "pod/$p -n kube-system" '{.status.phase}')" = Running ] &&
  [ "$(jsonpath alt "pod/$p -n kube-system" '{.status.containerStatuses[0].ready}')" = true ]
}
check "kube-controller-manager is running and ready" kcm_ok
check "all kubeconfig flags in the manifest point at an existing file" node_exec "$ALT_CP" "f=/etc/kubernetes/manifests/kube-controller-manager.yaml; [ \$(grep -c -- '--.*kubeconfig=' \$f) -ge 3 ] && for k in \$(grep -o -- '--[a-z-]*kubeconfig=[^ ]*' \$f | cut -d= -f2); do [ -f \"\$k\" ] || exit 1; done"
check "deployment reports has 2 ready pods" deploy_ready alt reports ops 2
check "deployment reports was not edited" bash -c "[ \"\$(kubectl --context alt -n ops get deploy reports -o jsonpath='{.spec.replicas} {.spec.template.spec.containers[0].image}')\" = \"2 $IMG_NGINX\" ]"
