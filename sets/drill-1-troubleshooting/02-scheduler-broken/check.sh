check "kube-scheduler pod is Running" bash -c "kubectl --context alt -n kube-system get pod kube-scheduler-$ALT_CP -o jsonpath='{.status.phase}' | grep -q Running && ! kubectl --context alt -n kube-system get pod kube-scheduler-$ALT_CP -o jsonpath='{.status.containerStatuses[0].state}' | grep -q waiting"
check "scheduler manifest runs kube-scheduler" node_exec "$ALT_CP" "grep -qE '^    - kube-scheduler\$' /etc/kubernetes/manifests/kube-scheduler.yaml"
check "deployment cart has 2 ready pods" deploy_ready alt cart checkout 2
check "deployment cart was not changed (still 2 replicas, same image)" bash -c "[ \"\$(kubectl --context alt -n checkout get deploy cart -o jsonpath='{.spec.replicas} {.spec.template.spec.containers[0].image}')\" = \"2 $IMG_NGINX\" ]"
