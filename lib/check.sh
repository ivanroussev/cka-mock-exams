# Grading helpers for check.sh files.
# Each `check` is one scoring point. The task's score = weight × passed / total.
# check.sh prints lines the runner parses: "PASS <desc>" or "FAIL <desc>".

check() { # check "description" command args...
  local desc="$1"; shift
  if ( "$@" ) >/dev/null 2>&1; then echo "PASS $desc"; else echo "FAIL $desc"; fi
}

# Common assertions (all return 0/1, quiet).
jp()        { local ctx="$1"; shift; kubectl --context "$ctx" get "$@" 2>/dev/null; } # raw get
jsonpath()  { kubectl --context "$1" get $2 -o jsonpath="$3" 2>/dev/null; }          # jsonpath main "deploy/x -n y" '{.spec.replicas}'
eq()        { [ "$1" = "$2" ]; }
contains()  { case "$1" in *"$2"*) return 0;; *) return 1;; esac; }
exists()    { kubectl --context "$1" get $2 >/dev/null 2>&1; }                        # exists main "pod/x -n y"
field_eq()  { [ "$(jsonpath "$1" "$2" "$3")" = "$4" ]; }                             # field_eq main "pod/x -n y" '{.spec.nodeName}' node1
field_has() { contains "$(jsonpath "$1" "$2" "$3")" "$4"; }
pod_ready() { [ "$(jsonpath "$1" "pod/$2 -n $3" '{.status.conditions[?(@.type=="Ready")].status}')" = "True" ]; }
deploy_ready() { # deploy_ready ctx name ns [replicas]
  local want="${4:-$(jsonpath "$1" "deploy/$2 -n $3" '{.spec.replicas}')}"
  [ -n "$want" ] && [ "$(jsonpath "$1" "deploy/$2 -n $3" '{.status.readyReplicas}')" = "$want" ]
}
node_ready() { [ "$(jsonpath "$1" "node/$2" '{.status.conditions[?(@.type=="Ready")].status}')" = "True" ]; }
can_i()     { [ "$(kubectl --context "$1" auth can-i $2 --as "$3" ${4:+-n $4} 2>/dev/null)" = "yes" ]; }
cannot_i()  { [ "$(kubectl --context "$1" auth can-i $2 --as "$3" ${4:+-n $4} 2>/dev/null)" = "no" ]; }
file_has()  { [ -f "$1" ] && grep -q -- "$2" "$1"; }
file_eq()   { [ -f "$1" ] && [ "$(tr -d '[:space:]' < "$1")" = "$(printf %s "$2" | tr -d '[:space:]')" ]; }
node_file_has() { node_exec "$1" "grep -q -- '$3' '$2'"; }

# HTTP from inside the cluster: http_ok ctx ns url [expected-substring]
# Runs a throwaway curl pod (image is pre-pulled), detached, then reads its log.
# The pod waits a few seconds first: NetworkPolicy agents need a moment to learn a new pod.
# _http ctx ns labels url → prints the body, then "__rc=<curl exit code>" (missing if the pod never ran).
_http() {
  local name="chk-$RANDOM$RANDOM" out
  kubectl --context "$1" -n "$2" run "$name" --image="$IMG_CURL" --restart=Never ${3:+--labels="$3"} \
    --command -- sh -c "sleep 4; curl -s -m 5 '$4'; rc=\$?; echo; echo __rc=\$rc" >/dev/null 2>&1 || return 0
  kubectl --context "$1" -n "$2" wait pod/"$name" --for=jsonpath='{.status.phase}'=Succeeded --timeout=45s >/dev/null 2>&1
  out="$(kubectl --context "$1" -n "$2" logs "$name" 2>/dev/null)"
  kubectl --context "$1" -n "$2" delete pod "$name" --wait=false >/dev/null 2>&1
  printf '%s\n' "$out"
}
_http_rc() { printf '%s\n' "$1" | sed -n 's/^__rc=//p' | tail -1; }
http_get_as() { # prints the body; fails unless curl ran and succeeded
  local out; out="$(_http "$1" "$2" "$3" "$4")"
  [ "$(_http_rc "$out")" = 0 ] || return 1
  printf '%s\n' "$out" | grep -v '^__rc='
}
http_get()  { http_get_as "$1" "$2" "" "$3"; }
http_ok()   { local out; out="$(http_get "$1" "$2" "$3")" || return 1; [ -z "$4" ] || contains "$out" "$4"; }
http_ok_as() { local out; out="$(http_get_as "$1" "$2" "$3" "$4")" || return 1; [ -z "$5" ] || contains "$out" "$5"; }
# Blocked = curl really ran and could not connect (a probe pod that never started doesn't count).
http_blocked_as() { local rc; rc="$(_http_rc "$(_http "$1" "$2" "$3" "$4")")"; [ -n "$rc" ] && [ "$rc" != 0 ]; }
http_blocked()    { http_blocked_as "$1" "$2" "" "$3"; }
