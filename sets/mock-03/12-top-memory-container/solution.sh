# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
save() { local f="$1" i=0; shift; while [ $i -lt 36 ]; do "$@" > "$f" 2>/dev/null && [ -s "$f" ] && return 0; i=$((i+1)); sleep 5; done; return 1; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
save "$ANSWERS/top-container.txt" bash -c 'kubectl --context main top pod -n analytics --containers --no-headers | awk '\''{m=$4; sub(/Mi$/,"",m); print m, $1"/"$2}'\'' | sort -rn | head -1 | awk '\''{print $2}'\'''
save "$ANSWERS/top-container-node.txt" bash -c 'kubectl --context main -n analytics get pod "$(cut -d/ -f1 "$ANSWERS/top-container.txt")" -o jsonpath='\''{.spec.nodeName}'\'''
