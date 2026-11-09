ns main corp-dns
COREDNS_IMG=$(kubectl --context main -n kube-system get deploy coredns -o jsonpath='{.spec.template.spec.containers[0].image}')
apply main <<YAML
apiVersion: v1
kind: ConfigMap
metadata: {name: corp-dns, namespace: corp-dns}
data:
  Corefile: |
    corp.internal:5353 {
        hosts {
            10.40.0.21 ledger.corp.internal
            10.40.0.37 vault.corp.internal
            10.40.0.52 git.corp.internal
        }
        errors
    }
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: corp-dns, namespace: corp-dns}
spec:
  replicas: 1
  selector: {matchLabels: {app: corp-dns}}
  template:
    metadata: {labels: {app: corp-dns}}
    spec:
      containers:
      - name: dns
        image: $COREDNS_IMG
        args: ["-conf", "/etc/coredns/Corefile"]
        ports: [{containerPort: 5353, protocol: UDP}, {containerPort: 5353, protocol: TCP}]
        volumeMounts: [{name: conf, mountPath: /etc/coredns}]
      volumes: [{name: conf, configMap: {name: corp-dns}}]
---
apiVersion: v1
kind: Service
metadata: {name: corp-dns, namespace: corp-dns}
spec:
  selector: {app: corp-dns}
  ports:
  - {name: dns, port: 53, targetPort: 5353, protocol: UDP}
  - {name: dns-tcp, port: 53, targetPort: 5353, protocol: TCP}
YAML
kubectl --context main -n corp-dns rollout status deploy/corp-dns --timeout=120s >/dev/null
