apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: portal, namespace: webcfg}
spec:
  containers:
  - name: portal
    image: $IMG_NGINX
    volumeMounts: [{name: bundle, mountPath: /etc/portal, readOnly: true}]
  volumes:
  - name: bundle
    projected:
      sources:
      - configMap:
          name: site-config
          items: [{key: site.conf, path: site.conf}]
      - secret:
          name: api-token
          items: [{key: token, path: auth/token}]
YAML
kubectl --context main -n webcfg wait --for=condition=Ready pod/portal --timeout=90s
