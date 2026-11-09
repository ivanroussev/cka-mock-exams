```bash
ssh cka-alt-control-plane                                  # here: ./cka ssh cka-alt-control-plane
grep -E 'listen-client|cert-file|key-file|trusted-ca' /etc/kubernetes/manifests/etcd.yaml   # where are the certs?
mkdir -p /opt/etcd-backup
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /opt/etcd-backup/pre-upgrade.db
etcdutl snapshot status /opt/etcd-backup/pre-upgrade.db -w table     # HASH | REVISION | TOTAL KEYS | SIZE
kubeadm certs check-expiration                                        # "apiserver" row
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate   # notAfter=…
```
Then, back on your workstation, write the revision and the date into the two answer files.

**Notes:** `snapshot save` talks to the running etcd, so it needs the endpoint and the client certs;
`snapshot status`/`restore` work on the file only and belong to `etcdutl` (the `etcdctl` variants are deprecated).
The certificate paths are always in the etcd static pod manifest — don't guess them.
