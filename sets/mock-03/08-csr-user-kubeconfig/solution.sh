# Retry API calls: on a busy laptop the API server sometimes times out the TLS handshake.
retry() { wait_for 180 "$@"; }
save() { local f="$1" i=0; shift; while [ $i -lt 36 ]; do "$@" > "$f" 2>/dev/null && [ -s "$f" ] && return 0; i=$((i+1)); sleep 5; done; return 1; }
apply() { local f; f=$(mktemp); cat > "$f"; retry kubectl --context "$1" apply -f "$f"; local r=$?; rm -f "$f"; return $r; }
cd "$ANSWERS"
openssl genrsa -out mira.key 2048 2>/dev/null
openssl req -new -key mira.key -subj "/CN=mira/O=release-eng" -out mira.csr
retry kubectl --context main apply -f - <<YAML
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata: {name: mira}
spec:
  request: $(base64 < mira.csr | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400
  usages: [client auth]
YAML
retry kubectl --context main certificate approve mira
wait_for 30 bash -c "[ -n \"\$(kubectl --context main get csr mira -o jsonpath='{.status.certificate}')\" ]"
save mira.crt bash -c 'kubectl --context main get csr mira -o jsonpath='\''{.status.certificate}'\'' | base64 --decode'
save ca.crt bash -c 'kubectl config view --raw --minify --context main -o jsonpath='\''{.clusters[0].cluster.certificate-authority-data}'\'' | base64 --decode'
for i in $(seq 1 36); do SERVER=$(kubectl config view --minify --context main -o jsonpath='{.clusters[0].cluster.server}' 2>/dev/null) && [ -n "$SERVER" ] && break; sleep 5; done
K=mira.kubeconfig
kubectl --kubeconfig $K config set-cluster main --server="$SERVER" --certificate-authority=ca.crt --embed-certs=true
kubectl --kubeconfig $K config set-credentials mira --client-certificate=mira.crt --client-key=mira.key --embed-certs=true
kubectl --kubeconfig $K config set-context mira@main --cluster=main --user=mira
kubectl --kubeconfig $K config use-context mira@main
retry kubectl --context main -n releases create role release-manager --verb=get,list,watch,update,patch --resource=deployments
retry kubectl --context main -n releases patch role release-manager --type=json -p='[{"op":"add","path":"/rules/-","value":{"apiGroups":[""],"resources":["pods","pods/log"],"verbs":["get","list"]}}]'
retry kubectl --context main -n releases create rolebinding release-manager --role=release-manager --group=release-eng
