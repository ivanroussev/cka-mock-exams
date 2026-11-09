ip=$(kubectl --context main -n legacy get pod erp-backend -o jsonpath='{.status.podIP}')
kubectl --context main -n legacy patch endpointslice erp-manual --type=json -p="[
  {\"op\":\"replace\",\"path\":\"/endpoints/0/addresses\",\"value\":[\"$ip\"]},
  {\"op\":\"replace\",\"path\":\"/ports/0\",\"value\":{\"name\":\"http\",\"port\":8080,\"protocol\":\"TCP\"}}]"
sleep 3
