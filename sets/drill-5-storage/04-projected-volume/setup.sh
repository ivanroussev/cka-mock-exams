ns main webcfg
kubectl --context main -n webcfg create configmap site-config --from-literal=site.conf='listen 8080;' --from-literal=extra.conf='unused' --dry-run=client -o yaml | kubectl --context main apply -f - >/dev/null
kubectl --context main -n webcfg create secret generic api-token --from-literal=token='s3cr3t-7f2a' --dry-run=client -o yaml | kubectl --context main apply -f - >/dev/null
