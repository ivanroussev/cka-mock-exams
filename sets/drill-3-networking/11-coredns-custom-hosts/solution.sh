kubectl --context alt -n kube-system get cm coredns -o json \
  | jq '.data.Corefile |= sub("(?<i> +)kubernetes cluster.local"; "\(.i)hosts {\n\(.i)   172.20.50.10 vault.corp.internal\n\(.i)   172.20.50.11 ldap.corp.internal\n\(.i)   fallthrough\n\(.i)}\n\(.i)kubernetes cluster.local")' \
  | kubectl --context alt replace -f - >/dev/null
kubectl --context alt -n kube-system rollout restart deploy/coredns >/dev/null
kubectl --context alt -n kube-system rollout status deploy/coredns --timeout=120s >/dev/null
