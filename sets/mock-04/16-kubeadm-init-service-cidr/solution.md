Docs page: **"Creating a cluster with kubeadm"**; `kubeadm init --help` lists the flags.

```bash
# On cp1
kubeadm init --pod-network-cidr 10.244.0.0/16 --service-cidr 10.112.0.0/16
mkdir -p ~/.kube && cp /etc/kubernetes/admin.conf ~/.kube/config
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

kubeadm token create --print-join-command > /root/join-command.txt   # or copy the one kubeadm init printed

# On w1
kubeadm join cp1:6443 --token … --discovery-token-ca-cert-hash sha256:…    # the line from join-command.txt

# On cp1
kubectl get nodes                       # both Ready
kubectl get svc kubernetes              # ClusterIP 10.112.0.1
```

**Pitfalls:** the service CIDR can't be changed after `init` without rebuilding — read the flags twice before pressing
Enter (`kubeadm reset -f` and re-init if you got it wrong; also `kubeadm reset -f` on `w1` if it already joined).
`--service-cidr` is the Service range, `--pod-network-cidr` the Pod range; flannel's default manifest expects `10.244.0.0/16`.
