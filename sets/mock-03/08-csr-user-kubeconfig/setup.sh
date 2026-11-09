ns main releases
kubectl --context main -n releases create deployment storefront --image="$IMG_NGINX" >/dev/null
kubectl --context main -n releases create secret generic registry-token --from-literal=token=s3cr3t >/dev/null
