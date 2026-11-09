kubectl --context main top pod -n batch --sort-by=cpu --no-headers | head -1 | awk '{print $1}' > "$ANSWERS/top-cpu-pod.txt"
kubectl --context main top node --no-headers | sort -k5 -rn | head -1 | awk '{print $1}' > "$ANSWERS/top-mem-node.txt"
