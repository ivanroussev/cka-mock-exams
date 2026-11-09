check "pod ram-share is Ready" pod_ready main ram-share scratch
check "volume cache: emptyDir medium Memory, sizeLimit 64Mi" bash -c "[ \"\$(kubectl --context main -n scratch get pod ram-share -o jsonpath='{.spec.volumes[?(@.name==\"cache\")].emptyDir.medium}|{.spec.volumes[?(@.name==\"cache\")].emptyDir.sizeLimit}')\" = 'Memory|64Mi' ]"
check "reader sees /data/status written by writer" bash -c "kubectl --context main -n scratch exec ram-share -c reader -- cat /data/status | grep -q ready"
check "reader's /data is tmpfs and read-only" bash -c "kubectl --context main -n scratch exec ram-share -c reader -- grep ' /data ' /proc/mounts | grep tmpfs | grep -q '[ ,]ro[ ,]'"
