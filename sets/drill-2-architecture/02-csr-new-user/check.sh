check "CSR mira is approved and issued by kube-apiserver-client" bash -c "
  [ \"\$(kubectl --context main get csr mira -o jsonpath='{.spec.signerName}')\" = kubernetes.io/kube-apiserver-client ] &&
  kubectl --context main get csr mira -o jsonpath='{.status.conditions[*].type}' | grep -q Approved &&
  [ -n \"\$(kubectl --context main get csr mira -o jsonpath='{.status.certificate}')\" ]"
check "mira.crt is the issued certificate for CN=mira, O=auditors matching mira.key" bash -c "
  s=\$(openssl x509 -in '$ANSWERS/mira.crt' -noout -subject) &&
  echo \"\$s\" | grep -q 'CN *= *mira' && echo \"\$s\" | grep -q 'O *= *auditors' &&
  [ \"\$(openssl x509 -in '$ANSWERS/mira.crt' -noout -pubkey)\" = \"\$(openssl pkey -in '$ANSWERS/mira.key' -pubout)\" ]"
check "context mira@main authenticates as mira" bash -c "[ \"\$(kubectl --context mira@main auth whoami -o jsonpath='{.status.userInfo.username}')\" = mira ]"
check "mira can list pods and read their logs in audit" bash -c "kubectl --context mira@main -n audit get pods >/dev/null && can_i main 'get pods' mira audit && can_i main 'get pods/log' mira audit"
check "mira cannot delete pods, read secrets or use other namespaces" bash -c "cannot_i main 'delete pods' mira audit && cannot_i main 'list pods' mira default && cannot_i main 'list secrets' mira audit"
