Docs: search **"Certificate Signing Requests"** → *Normal user* (how to issue a certificate for a user).
```bash
kubectl config use-context main
cd {{ANSWERS}}
openssl genrsa -out mira.key 2048
openssl req -new -key mira.key -subj "/CN=mira/O=auditors" -out mira.csr

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: mira
spec:
  request: $(base64 < mira.csr | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400
  usages: ["client auth"]
EOF
kubectl get csr                     # mira → Pending
kubectl certificate approve mira
kubectl get csr mira -o jsonpath='{.status.certificate}' | base64 -d > mira.crt

kubectl config set-credentials mira --client-key=mira.key --client-certificate=mira.crt --embed-certs=true
kubectl config get-contexts         # CLUSTER column of context main → kind-cka-main
kubectl config set-context mira@main --cluster=kind-cka-main --user=mira

kubectl -n audit create role log-reader --verb=get,list --resource=pods,pods/log
kubectl -n audit create rolebinding mira-log-reader --role=log-reader --user=mira

kubectl --context mira@main auth whoami
kubectl --context mira@main -n audit logs ledger-sync
kubectl auth can-i delete pods -n audit --as mira      # no
```
**Pitfalls:** the CN becomes the username and each O a group. `spec.request` is the base64 of the *whole* PEM CSR on one line.
`status.certificate` is base64 — decode it. Logs are the `pods/log` subresource, which `pods` alone does not cover.
Without `--embed-certs` the kubeconfig only points at files, which breaks as soon as they move.
