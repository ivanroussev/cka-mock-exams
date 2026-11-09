kubectl --context main -n edge expose deploy edge-web --name=edge-public --type=LoadBalancer --port=80 >/dev/null
kubectl --context main -n edge expose deploy edge-web --name=edge-peers --cluster-ip=None --port=80 >/dev/null
wait_for 120 bash -c "[ -n \"\$(kubectl --context main -n edge get svc edge-public -o jsonpath='{.status.loadBalancer.ingress[0].ip}')\" ]"
kubectl --context main -n edge get svc edge-public -o jsonpath='{.status.loadBalancer.ingress[0].ip}' > "$ANSWERS/edge-public-ip.txt"
ip="$(cat "$ANSWERS/edge-public-ip.txt")"
wait_for 120 bash -c "kubectl --context main -n edge run sol-\$RANDOM --image=$IMG_CURL --restart=Never --rm -i --quiet --command -- curl -s -m 5 http://$ip/ | grep -q 'It works'"
