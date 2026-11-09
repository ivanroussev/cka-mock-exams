check "container web uses nginx:1.28-alpine" field_eq main "deploy/quote-api -n quotes" '{.spec.template.spec.containers[?(@.name=="web")].image}' "$IMG_NGINX2"
check "3 replicas ready and fully rolled out" bash -c "[ \"\$(kubectl --context main -n quotes get deploy quote-api -o jsonpath='{.status.readyReplicas}/{.status.updatedReplicas}/{.spec.replicas}')\" = 3/3/3 ]"
check "rollout history shows the change cause" bash -c "kubectl --context main -n quotes rollout history deploy/quote-api | grep -q 'upgrade to nginx 1.28'"
