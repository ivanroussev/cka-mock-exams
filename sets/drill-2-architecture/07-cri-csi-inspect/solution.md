```bash
kubectl config use-context main
ssh cka-main-worker2                                    # here: ./cka ssh cka-main-worker2
# Where does the kubelet get its settings?
systemctl cat kubelet                                   # drop-in → /var/lib/kubelet/kubeadm-flags.env, --config=/var/lib/kubelet/config.yaml
grep -i runtime /var/lib/kubelet/kubeadm-flags.env /var/lib/kubelet/config.yaml
#   containerRuntimeEndpoint: unix:///run/containerd/containerd.sock   (or --container-runtime-endpoint=…)
crictl version                                          # RuntimeName: containerd   RuntimeVersion: v2.x.y
crictl info | head                                      # runtime status, CNI config
exit
echo unix:///run/containerd/containerd.sock > {{ANSWERS}}/cri-endpoint.txt
echo "containerd v2.x.y" > {{ANSWERS}}/cri-version.txt   # exactly what crictl printed

kubectl get storageclass                                # PROVISIONER column
kubectl get csidriver                                   # ATTACHREQUIRED column
echo files.csi.acme.io > {{ANSWERS}}/archive-provisioner.txt
kubectl get csidriver files.csi.acme.io -o jsonpath='{.spec.attachRequired}' > {{ANSWERS}}/archive-attach.txt
```
**What to know:** CRI = how the kubelet talks to the runtime (a gRPC socket; `crictl` uses the same one via `/etc/crictl.yaml`).
CSI = storage drivers; a CSIDriver object tells Kubernetes how to treat a driver (`attachRequired: false` → no VolumeAttachment / attach step).
`kubectl get nodes -o wide` shows the runtime too (`containerd://…`), but in a different format from `crictl version`.
