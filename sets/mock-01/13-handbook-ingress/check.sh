source "$TASK_DIR/../lib.sh"
check "Ingress handbook uses IngressClass traefik" field_eq main "ingress/handbook -n handbook" '{.spec.ingressClassName}' traefik
check "handbook.internal/api/... → handbook-api" bash -c "curl_pod main handbook -H 'Host: handbook.internal' http://traefik.traefik/api/v2/pages | grep -q '^handbook-api'"
check "handbook.internal/ → handbook-web" bash -c "curl_pod main handbook -H 'Host: handbook.internal' http://traefik.traefik/guides/onboarding | grep -q '^handbook-web'"
check "other hosts are not routed to handbook" bash -c "exists main 'ingress/handbook -n handbook' && ! curl_pod main handbook -H 'Host: wiki.internal' http://traefik.traefik/ | grep -q handbook"
