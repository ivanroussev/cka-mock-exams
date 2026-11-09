source "$TASK_DIR/../lib.sh"
ns main legacy
kubectl --context main -n legacy create configmap erp-conf --from-literal=default.conf="$(echo_conf "erp backend v7" 8080)" >/dev/null
apply main <<YAML
apiVersion: v1
kind: Pod
metadata: {name: erp-backend, namespace: legacy, labels: {app: erp-backend}}
spec:
  containers:
  - name: erp
    image: $IMG_NGINX
    ports: [{containerPort: 8080, name: http}]
    volumeMounts: [{name: conf, mountPath: /etc/nginx/conf.d}]
  volumes: [{name: conf, configMap: {name: erp-conf}}]
---
apiVersion: v1
kind: Service
metadata: {name: erp, namespace: legacy}
spec:
  ports: [{name: http, port: 80, targetPort: 8080, protocol: TCP}]
---
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: erp-manual
  namespace: legacy
  labels: {kubernetes.io/service-name: erp, endpointslice.kubernetes.io/managed-by: legacy-team}
addressType: IPv4
ports: [{name: web, port: 80, protocol: TCP}]
endpoints:
- addresses: ["10.244.250.17"]
  conditions: {ready: true}
YAML
kubectl --context main -n legacy wait pod/erp-backend --for=condition=Ready --timeout=120s >/dev/null
