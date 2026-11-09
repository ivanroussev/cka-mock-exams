ip=$(kubectl --context main -n legacy get pod redis-legacy -o jsonpath='{.status.podIP}')
apply main <<YAML
apiVersion: v1
kind: Service
metadata: {name: cache, namespace: bridge}
spec:
  ports: [{name: redis, port: 6379, targetPort: 6379, protocol: TCP}]
---
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: cache-1
  namespace: bridge
  labels: {kubernetes.io/service-name: cache}
addressType: IPv4
ports: [{name: redis, port: 6379, protocol: TCP}]
endpoints: [{addresses: ["$ip"]}]
YAML
kubectl --context main -n bridge expose deploy web --name=web-lb --type=LoadBalancer --port=80 --dry-run=client -o yaml \
  | awk '{print} /^spec:$/{print "  externalTrafficPolicy: Local"}' | kubectl --context main apply -f - >/dev/null
wait_for 60 bash -c "np=\$(kubectl --context main -n bridge get svc web-lb -o jsonpath='{.spec.ports[0].nodePort}'); n=\$(kubectl --context main -n bridge get pods -l app=web -o jsonpath='{.items[0].spec.nodeName}'); ip=\$(kubectl --context main get node \$n -o jsonpath='{.status.addresses[0].address}'); node_exec \$n \"curl -s -m 4 http://\$ip:\$np/\" | grep -q nginx"
