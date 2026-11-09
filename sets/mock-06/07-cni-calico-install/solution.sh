sed 's#value: "10.10.0.0/16"#value: "192.168.0.0/16"#' "$FILES/calico.yaml" | kubectl --context bare create -f - >/dev/null 2>&1
kubectl --context bare wait --for=condition=Ready nodes --all --timeout=420s >/dev/null
kubectl --context bare -n kube-system rollout status ds/calico-node --timeout=300s >/dev/null
kubectl --context bare run probe-b --image="$IMG_NGINX" >/dev/null
wait_for 180 pod_ready bare probe-b default
