node_exec "$ALT_CP" "sed -i 's/- kube-schedulerr$/- kube-scheduler/' /etc/kubernetes/manifests/kube-scheduler.yaml"
wait_for 180 deploy_ready alt cart checkout 2
