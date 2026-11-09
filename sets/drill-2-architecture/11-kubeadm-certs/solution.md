Docs: search **"Certificate Management with kubeadm"**.
```bash
ssh cka-alt-control-plane                     # here: ./cka ssh cka-alt-control-plane
kubeadm certs check-expiration
#   CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY ...
#   apiserver                  Nov 09, 2027 17:30 UTC   364d            ca
#   ...
#   CERTIFICATE AUTHORITY      EXPIRES                  RESIDUAL TIME
#   ca                         Nov 07, 2036 17:30 UTC   9y
exit
echo "Nov 07, 2036 17:30 UTC" > {{ANSWERS}}/ca-expiry.txt   # the value from YOUR cluster

ssh cka-alt-control-plane
kubeadm certs renew apiserver                 # not "renew all"
kubeadm certs check-expiration | grep apiserver
# Control-plane pods only read certificates at start-up → restart the API server:
mv /etc/kubernetes/manifests/kube-apiserver.yaml /tmp/ && sleep 20 && mv /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/
#   (or: crictl stop $(crictl ps --name kube-apiserver -q) and let kubelet restart it)
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate
```
**Pitfalls:** `kubeadm certs renew` only rewrites the files; the running API server keeps the old certificate until it restarts
(`kubectl delete pod` on a static pod's mirror does **not** restart it). The CA (10 years) can't be renewed with `kubeadm certs renew`.
`kubeadm upgrade apply` renews all certificates as a side effect.
