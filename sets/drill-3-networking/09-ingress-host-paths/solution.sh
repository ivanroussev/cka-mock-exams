kubectl --context alt -n blog create secret tls blog-tls --cert="$FILES/blog.crt" --key="$FILES/blog.key" >/dev/null
apply alt <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: {name: blog, namespace: blog}
spec:
  ingressClassName: traefik
  tls:
  - hosts: [blog.example.com]
    secretName: blog-tls
  rules:
  - host: blog.example.com
    http:
      paths:
      - {path: /dashboard, pathType: Exact, backend: {service: {name: blog-admin, port: {number: 80}}}}
      - {path: /, pathType: Prefix, backend: {service: {name: blog, port: {number: 80}}}}
YAML
ip="$(kubectl --context alt -n traefik get svc traefik -o jsonpath='{.spec.clusterIP}')"
wait_for 90 bash -c "kubectl --context alt -n blog run sol-\$RANDOM --image=$IMG_CURL --restart=Never --rm -i --quiet --command -- curl -sk -m 5 --resolve blog.example.com:443:$ip https://blog.example.com/dashboard | grep -q 'admin panel'"
