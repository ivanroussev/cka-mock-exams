# Requests go to the traefik Service's ClusterIP (no DNS needed, so a CoreDNS change on alt can't interfere).
TRAEFIK="$(kubectl --context alt -n traefik get svc traefik -o jsonpath='{.spec.clusterIP}' 2>/dev/null)"
via_traefik() { # via_traefik <path> <expected text> — HTTPS with SNI blog.example.com; -v so the served certificate shows up
  kubectl --context alt -n blog run "chk-$RANDOM$RANDOM" --image="$IMG_CURL" --restart=Never --rm -i --quiet \
    --command -- sh -c "sleep 3; curl -skv -m 5 --retry 3 --retry-all-errors --resolve blog.example.com:443:${TRAEFIK:-0.0.0.0} https://blog.example.com$1 2>&1" 2>/dev/null | grep -q "$2"
}
export -f via_traefik; export TRAEFIK
check "Secret blog-tls is a kubernetes.io/tls Secret for blog.example.com" bash -c "[ \"\$(kubectl --context alt -n blog get secret blog-tls -o jsonpath='{.type}')\" = kubernetes.io/tls ] && kubectl --context alt -n blog get secret blog-tls -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -subject | grep -q blog.example.com"
check "Ingress blog uses IngressClass traefik" field_eq alt "ingress/blog -n blog" '{.spec.ingressClassName}' traefik
check "https://blog.example.com serves the blog-tls certificate" via_traefik /posts/7 "subject: CN=blog.example.com"
check "/dashboard → blog-admin" via_traefik /dashboard "blog admin panel"
check "/dashboard/settings → blog (Exact match only), /posts/7 → blog" bash -c "via_traefik /dashboard/settings 'blog home page' && via_traefik /posts/7 'blog home page'"
