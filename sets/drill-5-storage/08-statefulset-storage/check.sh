check "service kv is headless" field_eq main "svc/kv -n kvstore" '{.spec.clusterIP}' None
check "statefulset kv has 2 ready replicas and uses service kv" bash -c "[ \"\$(kubectl --context main -n kvstore get sts kv -o jsonpath='{.status.readyReplicas}|{.spec.serviceName}')\" = '2|kv' ]"
check "PVCs data-kv-0 and data-kv-1 are Bound" bash -c "for i in 0 1; do [ \"\$(kubectl --context main -n kvstore get pvc data-kv-\$i -o jsonpath='{.status.phase}|{.spec.storageClassName}|{.spec.resources.requests.storage}')\" = 'Bound|standard|256Mi' ] || exit 1; done"
check "claim template data is mounted at /data" bash -c "kubectl --context main -n kvstore get sts kv -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[?(@.name==\"data\")].mountPath}' | grep -qx /data"
