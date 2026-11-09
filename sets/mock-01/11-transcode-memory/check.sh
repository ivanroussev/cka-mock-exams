check "top memory transcode pod is media-us/encode-us-1" file_eq "$ANSWERS/transcode-top-mem.txt" "media-us/encode-us-1"
check "node of that pod" bash -c "file_eq '$ANSWERS/transcode-top-mem-node.txt' \"\$(kubectl --context main -n media-us get pod encode-us-1 -o jsonpath='{.spec.nodeName}')\""
