source "$TASK_DIR/../lib.sh"
kubectl --context main -n billing expose deploy billing-ui --port 80
kubectl --context main -n billing create secret tls billing-tls --cert="$FILES/billing.crt" --key="$FILES/billing.key"
kubectl --context main -n billing create ingress billing --class=traefik --rule="billing.example.test/*=billing-ui:80,tls=billing-tls"
ip="$(kubectl --context main -n traefik get svc traefik -o jsonpath='{.spec.clusterIP}')"
wait_for 180 bash -c "curl_pod_sh main billing \"curl -sk -m 5 --resolve billing.example.test:443:$ip https://billing.example.test/\" | grep -q 'billing ui'"
