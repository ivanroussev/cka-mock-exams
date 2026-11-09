ns main ledger
apply main <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: accounts, namespace: ledger}
spec:
  replicas: 2
  selector: {matchLabels: {app: accounts}}
  template:
    metadata: {labels: {app: accounts}}
    spec:
      containers:
      - name: api
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "mkdir -p /www && echo 'accounts: balance service ok' > /www/index.html && exec httpd -f -p 9090 -h /www"]
        ports: [{name: web, containerPort: 9090}]
---
apiVersion: v1
kind: Service
metadata: {name: accounts, namespace: ledger}
spec:
  selector: {app: accounts}
  ports: [{name: http, port: 8080, targetPort: 8080}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: teller, namespace: ledger}
spec:
  replicas: 1
  selector: {matchLabels: {app: teller}}
  template:
    metadata: {labels: {app: teller}}
    spec:
      dnsPolicy: Default
      containers:
      - name: teller
        image: $IMG_BUSYBOX
        command: ["sh", "-c", "while true; do if out=\$(wget -qO- -T 2 http://accounts:8080 2>&1); then echo \"\$(date +%T) OK \$out\"; else echo \"\$(date +%T) ERROR calling http://accounts:8080: \$out\"; fi; sleep 5; done"]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: default-deny-all, namespace: ledger}
spec:
  podSelector: {}
  policyTypes: [Ingress, Egress]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: allow-dns-egress, namespace: ledger}
spec:
  podSelector: {}
  policyTypes: [Egress]
  egress:
  - to:
    - namespaceSelector: {matchLabels: {kubernetes.io/metadata.name: kube-system}}
      podSelector: {matchLabels: {k8s-app: kube-dns}}
    ports: [{protocol: UDP, port: 53}, {protocol: TCP, port: 53}]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: accounts-ingress, namespace: ledger}
spec:
  podSelector: {matchLabels: {app: accounts}}
  policyTypes: [Ingress]
  ingress:
  - from: [{podSelector: {matchLabels: {app: teller}}}]
    ports: [{protocol: TCP, port: 9090}]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: teller-egress, namespace: ledger}
spec:
  podSelector: {matchLabels: {app: teller}}
  policyTypes: [Egress]
  egress:
  - to: [{podSelector: {matchLabels: {app: accounts}}}]
    ports: [{protocol: TCP, port: 8080}]
YAML
kubectl --context main -n ledger rollout status deploy/teller --timeout=120s >/dev/null
kubectl --context main -n ledger rollout status deploy/accounts --timeout=120s >/dev/null
