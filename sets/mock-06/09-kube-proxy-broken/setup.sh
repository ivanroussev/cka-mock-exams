# Break kube-proxy's config, then restart the kube-proxy pod on the control plane so it picks it up.
kubectl --context alt -n kube-system get cm kube-proxy -o yaml | sed 's/^    mode: .*/    mode: "iptabels"/' | kubectl --context alt apply -f - >/dev/null 2>&1
kubectl --context alt -n kube-system delete pod -l k8s-app=kube-proxy --field-selector spec.nodeName=$ALT_CP --wait=false >/dev/null
ns alt api
apply alt <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: quotes, namespace: api}
spec:
  replicas: 2
  selector: {matchLabels: {app: quotes}}
  template:
    metadata: {labels: {app: quotes}}
    spec:
      tolerations: [{key: node-role.kubernetes.io/control-plane, operator: Exists, effect: NoSchedule}]
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms: [{matchExpressions: [{key: node-role.kubernetes.io/control-plane, operator: Exists}]}]
      containers:
      - name: quotes
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "mkdir -p /www && echo 'quote of the day: it works' > /www/index.html && exec httpd -f -p 9000 -h /www"]
        ports: [{containerPort: 9000}]
YAML
wait_for 60 bash -c "kubectl --context alt -n kube-system get pods -l k8s-app=kube-proxy --field-selector spec.nodeName=$ALT_CP -o jsonpath='{.items[0].status.containerStatuses[0].restartCount}' | grep -qv '^0\$'"
kubectl --context alt -n api expose deploy quotes --port=8080 --target-port=9000 >/dev/null
kubectl --context alt -n api rollout status deploy/quotes --timeout=120s >/dev/null
