```bash
ssh cka-alt-control-plane                        # here: ./cka ssh cka-alt-control-plane
# 1. stop the API server (static pod): move its manifest away
mv /etc/kubernetes/manifests/kube-apiserver.yaml /root/
# 2. restore the snapshot into a NEW data dir (works on the file only — no endpoint/certs needed)
etcdutl snapshot restore /opt/etcd-backup/inventory.db --data-dir /var/lib/etcd-restored
# 3. point etcd at it: change the hostPath of the etcd-data volume
vim /etc/kubernetes/manifests/etcd.yaml
#    volumes:
#    - hostPath:
#        path: /var/lib/etcd-restored        # was /var/lib/etcd
#      name: etcd-data
crictl ps | grep etcd                            # wait until etcd is running again (~30 s)
# 4. start the API server again
mv /root/kube-apiserver.yaml /etc/kubernetes/manifests/
exit
kubectl config use-context alt
kubectl -n inventory get cm                      # price-rules and warehouse-map are back
```
**Notes:** only the **hostPath** has to change — the container still mounts it at `/var/lib/etcd`, so `--data-dir`
stays as it is. (Alternatively change both `--data-dir` and the mount consistently.) The docs ("Operating etcd clusters
for Kubernetes" → *Restoring an etcd cluster*) say to stop the API servers before restoring and start them afterwards,
so they don't keep serving cached data from before the restore; restarting the kubelets afterwards
(`systemctl restart kubelet`) makes nodes re-report their status right away. `etcdctl snapshot restore` still works but is deprecated
in favour of `etcdutl`.
