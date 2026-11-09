source "$TASK_DIR/../lib.sh"
kubectl --context main -n handbook create ingress handbook --class=traefik \
  --rule="handbook.internal/api*=handbook-api:8080" --rule="handbook.internal/*=handbook-web:80"
wait_for 60 bash -c "curl_pod main handbook -H 'Host: handbook.internal' http://traefik.traefik/api | grep -q handbook-api"
