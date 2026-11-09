check "release kvcache deployed in cache-system with the requested values" bash -c "
  helm --kube-context main -n cache-system status kvcache -o json 2>/dev/null | grep -q '\"status\":\"deployed\"' &&
  v=\$(helm --kube-context main -n cache-system get values kvcache -o json 2>/dev/null | tr -d ' \n') &&
  case \"\$v\" in *'\"replicaCount\":2'*) ;; *) exit 1;; esac && case \"\$v\" in *'\"logLevel\":\"debug\"'*) ;; *) exit 1;; esac && case \"\$v\" in *'\"watchNamespace\":\"sessions\"'*) ;; *) exit 1;; esac"
check "operator runs 2 ready replicas watching sessions" bash -c "
  deploy_ready main kvcache-operator cache-system 2 &&
  [ \"\$(kubectl --context main -n cache-system get deploy kvcache-operator -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name==\"WATCH_NAMESPACE\")].value} {.spec.template.spec.containers[0].env[?(@.name==\"LOG_LEVEL\")].value}')\" = 'sessions debug' ]"
check "CRD list written" bash -c "[ \"\$(grep -v '^[[:space:]]*\$' '$ANSWERS/kvcache-crds.txt' | sed 's/^ *//;s/ *\$//;s#^customresourcedefinition[^/]*/##' | sort | tr '\n' ' ')\" = 'kvcachebackups.cache.example.io kvcaches.cache.example.io ' ]"
check "KVCache session-store: 3 replicas, 512Mi, allkeys-lru" bash -c "
  [ \"\$(kubectl --context main -n sessions get kvcaches.cache.example.io session-store -o jsonpath='{.spec.replicas} {.spec.memory} {.spec.eviction.policy}')\" = '3 512Mi allkeys-lru' ]"
