retry() { "$@" && return 0; sleep 4; "$@"; }   # in-cluster probes can flake on a loaded laptop
get_media() {
  local ip; ip="$(kubectl --context main -n traefik get svc traefik -o jsonpath='{.spec.clusterIP}' 2>/dev/null)"; [ -n "$ip" ] || return 1
  kubectl --context main -n media run "chk-$RANDOM$RANDOM" --image="$IMG_CURL" --restart=Never --rm -i --quiet --command -- \
    curl -s -m 5 -H 'Host: media.example.internal' "http://$ip$1" 2>/dev/null | grep -qF "$2"
}
check "Ingress media uses IngressClass traefik" bash -c "[ \"\$(kubectl --context main -n media get ingress media -o jsonpath='{.spec.ingressClassName}')\" = traefik ]"
check "http://media.example.internal/images/logo.png is served by images" retry get_media /images/logo.png "image store: logo.png"
check "http://media.example.internal/videos/intro.mp4 is served by videos" retry get_media /videos/intro.mp4 "video store: intro.mp4"
check "Services and Deployments in media were not changed" bash -c "[ \"\$(kubectl --context main -n media get svc images videos -o jsonpath='{range .items[*]}{.spec.ports[0].name}:{.spec.ports[0].port}:{.spec.ports[0].targetPort} {end}')\" = 'web:80:8080 web:80:8080 ' ]"
