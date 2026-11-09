ns alt release
kubectl --context alt -n release create serviceaccount deploy-bot >/dev/null
kubectl --context alt -n release create deployment web --image=$IMG_NGINX --replicas=0 >/dev/null
