kubectl --context main top pod collector -n telemetry --containers --no-headers | sort -k3 -rn | head -1 | awk '{print $2}' > "$ANSWERS/telemetry-cpu.txt"
kubectl --context main top pod -n telemetry -l tier=buffer --sort-by=memory --no-headers | head -1 | awk '{print $1}' > "$ANSWERS/telemetry-mem.txt"
