check "top CPU pod is report-x7" file_eq "$ANSWERS/top-cpu-pod.txt" "report-x7"
# Node memory changes over time, so accept the node that is highest now, or within 3 points of it.
check "top memory node" bash -c '
  want=$(tr -d "[:space:]" < "$ANSWERS/top-mem-node.txt" 2>/dev/null); [ -n "$want" ] || exit 1
  kubectl --context main top nodes --no-headers | awk -v w="$want" "{gsub(\"%\",\"\",\$5); p[\$1]=\$5; if (\$5>max) max=\$5} END {exit !((w in p) && p[w] >= max-3)}"'
