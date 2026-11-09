check "ConfigMap docs-site is immutable and has both keys" bash -c "
  [ \"\$(kubectl --context main -n docs get cm docs-site -o jsonpath='{.immutable}|{.data.release}')\" = 'true|3' ] &&
  kubectl --context main -n docs get cm docs-site -o jsonpath='{.data.index\.html}' | grep -q 'Product docs, release 3'"
check "pod docs serves index.html from the ConfigMap" bash -c "
  kubectl --context main -n docs exec docs -- wget -qO- http://127.0.0.1/ | grep -q 'Product docs, release 3'"
check "release key is not mounted in the web root" bash -c "
  kubectl --context main -n docs exec docs -- test -f /usr/share/nginx/html/index.html &&
  ! kubectl --context main -n docs exec docs -- test -e /usr/share/nginx/html/release"
check "Secret docs-auth mounted read-only at /etc/docs-auth with mode 0400" bash -c "
  [ \"\$(kubectl --context main -n docs get pod docs -o jsonpath='{.spec.containers[0].volumeMounts[?(@.mountPath==\"/etc/docs-auth\")].readOnly}')\" = true ] &&
  [ \"\$(kubectl --context main -n docs exec docs -- cat /etc/docs-auth/token)\" = tk-7f3a91 ] &&
  [ \"\$(kubectl --context main -n docs exec docs -- stat -L -c %a /etc/docs-auth/token)\" = 400 ]"
