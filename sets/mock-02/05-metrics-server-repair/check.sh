check "metrics-server Deployment is ready" deploy_ready main metrics-server kube-system
check "kubectl top nodes / pods work" bash -c "kubectl --context main top nodes --no-headers | grep -q . && kubectl --context main top pods -n render-farm --no-headers | grep -q frame-0"
check "top CPU pod in render-farm is frame-03" file_eq "$ANSWERS/render-top-cpu.txt" "frame-03"
