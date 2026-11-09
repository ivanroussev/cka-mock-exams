check "blue-claim is Bound to pv-blue" bash -c "[ \"\$(kubectl --context main -n teams get pvc blue-claim -o jsonpath='{.status.phase}|{.spec.volumeName}')\" = 'Bound|pv-blue' ]"
check "blue-claim selects team=blue by label" bash -c "kubectl --context main -n teams get pvc blue-claim -o jsonpath='{.spec.selector}' | grep -q blue"
check "pod blue-app is Ready" pod_ready main blue-app teams
check "pod mounts blue-claim with subPath blue-app" bash -c "kubectl --context main -n teams get pod blue-app -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath==\"/work\")].subPath}' | grep -qx blue-app"
check "hello.txt is in the blue-app sub-directory of pv-blue" node_exec "$MAIN_W1" "grep -q hello /srv/teams/blue/blue-app/hello.txt"
