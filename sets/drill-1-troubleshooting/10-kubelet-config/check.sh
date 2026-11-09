check "kubelet on $BARE_W1 is healthy (:10248/healthz)" node_exec "$BARE_W1" "curl -sf -m 3 http://127.0.0.1:10248/healthz"
check "kubelet is enabled at boot" node_exec "$BARE_W1" "systemctl is-enabled kubelet"
check "kubelet runs with a config file that exists" node_exec "$BARE_W1" 'f=$(tr "\0" " " < /proc/$(pidof kubelet)/cmdline | grep -o -- "--config=[^ ]*" | cut -d= -f2); [ -n "$f" ] && [ -f "$f" ]'
check "systemd has no pending unit changes (daemon-reload done)" node_exec "$BARE_W1" '[ "$(systemctl show kubelet -p NeedDaemonReload --value)" = no ]'
