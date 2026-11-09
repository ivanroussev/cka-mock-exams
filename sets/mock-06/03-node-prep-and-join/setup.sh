node_exec "$MAIN_W2" "rm -f /etc/sysctl.d/k8s.conf /etc/modules-load.d/k8s.conf"
node_exec "$MAIN_CP" "rm -f /root/join-worker.sh"
