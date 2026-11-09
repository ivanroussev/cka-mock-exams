{ kubectl --context main -n docs create configmap docs-site --from-file=index.html="$FILES/index.html" --from-literal=release=3 --dry-run=client -o yaml
  echo "immutable: true"; } | kubectl --context main apply -f -
kubectl --context main -n docs create secret generic docs-auth --from-literal=token=tk-7f3a91
apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: docs, namespace: docs}
spec:
  containers:
  - name: docs
    image: $IMG_NGINX
    volumeMounts:
    - {name: site, mountPath: /usr/share/nginx/html}
    - {name: auth, mountPath: /etc/docs-auth, readOnly: true}
  volumes:
  - name: site
    configMap:
      name: docs-site
      items: [{key: index.html, path: index.html}]
  - name: auth
    secret: {secretName: docs-auth, defaultMode: 0400}
YAML
kubectl --context main -n docs wait --for=condition=Ready pod/docs --timeout=120s
