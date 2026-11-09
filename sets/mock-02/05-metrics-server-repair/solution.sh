kubectl --context main -n kube-system patch deploy metrics-server --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl --context main -n kube-system rollout status deploy/metrics-server --timeout=180s
wait_for 180 bash -c "[ \$(kubectl --context main top pods -n render-farm --no-headers | grep -c frame-0) -eq 4 ]"
kubectl --context main top pod -n render-farm --sort-by=cpu --no-headers | head -1 | awk '{print $1}' > "$ANSWERS/render-top-cpu.txt"
