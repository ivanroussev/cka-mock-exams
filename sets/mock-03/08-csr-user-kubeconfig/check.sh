K="$ANSWERS/mira.kubeconfig"
mk() { kubectl --kubeconfig "$ANSWERS/mira.kubeconfig" "$@"; }
export -f mk
check "CSR mira approved and issued (client signer, 1 day)" bash -c "
  [ \"\$(kubectl --context main get csr mira -o jsonpath='{.spec.signerName} {.spec.expirationSeconds} {.status.conditions[?(@.type==\"Approved\")].status}')\" = 'kubernetes.io/kube-apiserver-client 86400 True' ] &&
  [ -n \"\$(kubectl --context main get csr mira -o jsonpath='{.status.certificate}')\" ]"
check "mira.crt is the issued certificate for CN=mira, O=release-eng matching mira.key" bash -c "
  s=\$(openssl x509 -in '$ANSWERS/mira.crt' -noout -subject 2>/dev/null | tr -d ' ')
  case \"\$s\" in *CN=mira*) ;; *) exit 1;; esac; case \"\$s\" in *O=release-eng*) ;; *) exit 1;; esac
  [ \"\$(openssl x509 -in '$ANSWERS/mira.crt' -noout -pubkey)\" = \"\$(openssl pkey -in '$ANSWERS/mira.key' -pubout 2>/dev/null)\" ]"
check "kubeconfig: current context mira@main works as mira, certs embedded" bash -c "
  [ \"\$(kubectl --kubeconfig '$K' config current-context)\" = mira@main ] &&
  [ \"\$(mk config view --raw --minify -o jsonpath='{.users[0].user.client-certificate}{.users[0].user.client-key}{.clusters[0].cluster.certificate-authority}')\" = '' ] &&
  mk -n releases get deploy storefront && [ \"\$(mk auth whoami -o jsonpath='{.status.userInfo.username}')\" = mira ]"
check "mira can read/update deployments and read pod logs in releases" bash -c "
  for a in 'get deployments' 'list deployments' 'watch deployments' 'update deployments' 'patch deployments' 'get pods' 'list pods' 'get pods --subresource=log'; do
    [ \"\$(mk auth can-i \$a -n releases)\" = yes ] || exit 1; done"
check "nothing more: no delete/create, no secrets, no other namespaces; bound to the group" bash -c "
  for a in 'delete deployments' 'create deployments' 'get secrets' 'delete pods' 'create pods --subresource=exec'; do
    [ \"\$(mk auth can-i \$a -n releases)\" = no ] || exit 1; done
  [ \"\$(mk auth can-i list deployments -n default)\" = no ] &&
  [ \"\$(kubectl --context main -n releases get rolebinding release-manager -o jsonpath='{.roleRef.kind}/{.roleRef.name} {.subjects[*].kind}/{.subjects[*].name}')\" = 'Role/release-manager Group/release-eng' ]"
