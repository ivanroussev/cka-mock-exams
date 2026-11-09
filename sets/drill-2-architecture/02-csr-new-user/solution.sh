cd "$ANSWERS"
openssl genrsa -out mira.key 2048 2>/dev/null
openssl req -new -key mira.key -subj "/CN=mira/O=auditors" -out mira.csr
kc main apply -f - <<YAML
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata: {name: mira}
spec:
  request: $(base64 < mira.csr | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400
  usages: ["client auth"]
YAML
kc main certificate approve mira
wait_for 60 bash -c "[ -n \"\$(kubectl --context main get csr mira -o jsonpath='{.status.certificate}')\" ]"
kc main get csr mira -o jsonpath='{.status.certificate}' | base64 -d > mira.crt
kubectl config set-credentials mira --client-key=mira.key --client-certificate=mira.crt --embed-certs=true
kubectl config set-context mira@main --user=mira \
  --cluster="$(kubectl config view -o jsonpath='{.contexts[?(@.name=="main")].context.cluster}')"
kc main -n audit create role log-reader --verb=get,list --resource=pods,pods/log
kc main -n audit create rolebinding mira-log-reader --role=log-reader --user=mira
