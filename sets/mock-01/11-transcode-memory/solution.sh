kubectl --context main top pod -A -l tier=transcode --sort-by=memory --no-headers | head -1 | awk '{print $1"/"$2}' > "$ANSWERS/transcode-top-mem.txt"
p="$(cat "$ANSWERS/transcode-top-mem.txt")"
kubectl --context main -n "${p%/*}" get pod "${p#*/}" -o jsonpath='{.spec.nodeName}' > "$ANSWERS/transcode-top-mem-node.txt"
