# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
save() { local f="$1" i=0; shift; while [ $i -lt 36 ]; do "$@" > "$f" 2>/dev/null && [ -s "$f" ] && return 0; i=$((i+1)); sleep 5; done; return 1; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
save "$ANSWERS/data-top-pod.txt" bash -c 'kubectl --context main top pod -A -l team=data --no-headers | awk '\''{c=$3; sub(/m$/,"",c); print c, $1"/"$2}'\'' | sort -rn | head -1 | awk '\''{print $2}'\'''
export P=$(cat "$ANSWERS/data-top-pod.txt")
save "$ANSWERS/data-top-container.txt" bash -c 'kubectl --context main top pod -n "${P%/*}" "${P#*/}" --containers --no-headers | awk '\''{c=$3; sub(/m$/,"",c); print c, $2}'\'' | sort -rn | head -1 | awk '\''{print $2}'\'''
