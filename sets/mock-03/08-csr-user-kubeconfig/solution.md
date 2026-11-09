```bash
cd {{ANSWERS}}
openssl genrsa -out mira.key 2048
openssl req -new -key mira.key -subj "/CN=mira/O=release-eng" -out mira.csr
cat <<EOF2 | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata: {name: mira}
spec:
  request: $(base64 < mira.csr | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400
  usages: [client auth]
EOF2
kubectl certificate approve mira
kubectl get csr mira -o jsonpath='{.status.certificate}' | base64 -d > mira.crt

kubectl config view --raw --minify -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > ca.crt
SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
kubectl --kubeconfig mira.kubeconfig config set-cluster main --server=$SERVER --certificate-authority=ca.crt --embed-certs
kubectl --kubeconfig mira.kubeconfig config set-credentials mira --client-certificate=mira.crt --client-key=mira.key --embed-certs
kubectl --kubeconfig mira.kubeconfig config set-context mira@main --cluster=main --user=mira
kubectl --kubeconfig mira.kubeconfig config use-context mira@main

kubectl -n releases create role release-manager --verb=get,list,watch,update,patch --resource=deployments
kubectl -n releases edit role release-manager      # add a second rule:
#   - apiGroups: [""]
#     resources: ["pods", "pods/log"]
#     verbs: ["get", "list"]
kubectl -n releases create rolebinding release-manager --role=release-manager --group=release-eng

kubectl --kubeconfig mira.kubeconfig auth whoami
kubectl --kubeconfig mira.kubeconfig -n releases auth can-i patch deploy      # yes
kubectl --kubeconfig mira.kubeconfig -n releases auth can-i get secrets       # no
```
**Pitfalls:** the group comes from the certificate's `O=` field — binding the user name would also work for mira, but the task asks
for the group. `kubectl create role` gives every verb to every listed resource, so differing verbs need a second rule.
Docs: "Certificates and Certificate Signing Requests → Normal user".
