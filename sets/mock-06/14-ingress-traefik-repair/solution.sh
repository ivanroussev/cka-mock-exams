apply main <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: {name: media, namespace: media}
spec:
  ingressClassName: traefik
  rules:
  - host: media.example.internal
    http:
      paths:
      - path: /images
        pathType: Prefix
        backend: {service: {name: images, port: {name: web}}}
      - path: /videos
        pathType: Prefix
        backend: {service: {name: videos, port: {number: 80}}}
YAML
wait_for 60 bash -c "ip=\$(kubectl --context main -n traefik get svc traefik -o jsonpath='{.spec.clusterIP}'); kubectl --context main -n media run sol-\$RANDOM --image=$IMG_CURL --restart=Never --rm -i --quiet --command -- curl -s -m 5 -H 'Host: media.example.internal' http://\$ip/videos/intro.mp4 | grep -q intro"
