# CKA cheat sheet (Kubernetes v1.37)

## First 60 seconds of the exam

The exam terminal already has `alias k=kubectl` and bash completion. Add these:

```bash
export do="--dry-run=client -o yaml"     # k create deploy x --image=nginx $do > x.yaml
export now="--force --grace-period=0"    # k delete pod x $now
```

`~/.vimrc` (vim is the default editor):

```vim
set expandtab tabstop=2 shiftwidth=2 number
```

**On every question:** copy the `kubectl config use-context …` line first. Forgetting it is the most common way to lose points.

## Generate YAML instead of writing it

```bash
k run web --image=nginx:1.27-alpine --port=80 --labels=app=web $do
k create deploy web --image=nginx:1.27-alpine --replicas=3 $do
k create svc clusterip web --tcp=80:8080 $do              # or: k expose deploy web --port=80 --target-port=8080
k create cm app --from-literal=MODE=prod --from-file=app.conf $do
k create secret generic db --from-literal=password=s3cret $do
k create job once --image=busybox:1.37 $do -- sh -c 'echo hi'
k create cronjob nightly --image=busybox:1.37 --schedule='0 2 * * *' $do -- date
k create role reader --verb=get,list,watch --resource=pods,services -n dev $do
k create rolebinding reader --role=reader --serviceaccount=dev:app -n dev $do
k create clusterrole node-viewer --verb=get,list --resource=nodes $do
k create sa app -n dev
k create ingress web --rule='shop.example.com/=web:80' --class=traefik $do
k create pdb web --selector=app=web --min-available=2 $do
k create quota q --hard=pods=10,requests.cpu=2 -n dev $do
k autoscale deploy web --cpu=50% --min=2 --max=8 $do       # keep the %: --cpu=50 means 50 millicores. Edit in behavior: if asked
k create priorityclass high --value=1000 $do
```

There's no generator for these. Search kubernetes.io/docs and copy the example: **PV/PVC, StorageClass, NetworkPolicy, DaemonSet, StatefulSet, Gateway/HTTPRoute, probes, affinity, tolerations, topologySpreadConstraints, LimitRange**.

## Find things fast

```bash
k explain pod.spec.containers.livenessProbe --recursive | less
k api-resources | grep -i gateway
k get po -A -o wide --sort-by=.metadata.creationTimestamp
k get po -l app=web -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\n"}{end}'
k get events -A --sort-by=.lastTimestamp | tail -20        # or: k events -n dev
k auth can-i list secrets --as=system:serviceaccount:dev:app -n dev
k auth whoami
```

## Troubleshooting order

1. `k get nodes`, then `k describe node X` (Conditions, Taints)
2. On the node: `systemctl status kubelet` and `journalctl -u kubelet -e --no-pager | tail -50`
3. Control-plane pods are static pods, defined in `/etc/kubernetes/manifests/`. Edit the file there; kubelet picks up the change by itself.
4. If kubectl doesn't work: `crictl ps -a | grep apiserver`, then `crictl logs <id>`, and check `/var/log/pods/kube-system_kube-apiserver-*`
5. Pods: `k describe po` (Events) → `k logs po -c container --previous`
6. Services: are there endpoints (`k get endpointslices -l kubernetes.io/service-name=X`)? Do the selector and the pod labels match? Is the targetPort right?
7. DNS: `k run t --rm -it --image=busybox:1.37 --restart=Never -- nslookup web.dev.svc.cluster.local`, then check the CoreDNS pods and `k -n kube-system get cm coredns -o yaml`

## kubeadm and etcd (VM lab)

```bash
# Upgrade, control plane (docs: "Upgrading kubeadm clusters")
sed -i 's#/v1.36/#/v1.37/#' /etc/apt/sources.list.d/kubernetes.list && apt-get update
apt-mark unhold kubeadm && apt-get install -y kubeadm='1.37.*' && apt-mark hold kubeadm
kubeadm upgrade plan && kubeadm upgrade apply v1.37.x
k drain cp1 --ignore-daemonsets
apt-mark unhold kubelet kubectl && apt-get install -y kubelet='1.37.*' kubectl='1.37.*' && apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet && k uncordon cp1
# Worker: the same, but `kubeadm upgrade node`

kubeadm token create --print-join-command                     # join a worker
kubeadm init phase upload-certs --upload-certs                # get a --certificate-key to join a control plane
kubeadm join lb:6443 --token … --discovery-token-ca-cert-hash sha256:… --control-plane --certificate-key …
kubeadm certs check-expiration ; kubeadm certs renew apiserver

# etcd backup and restore
etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /opt/backup/etcd.db
etcdutl snapshot restore /opt/backup/etcd.db --data-dir /var/lib/etcd-restore
# then set the etcd-data hostPath in /etc/kubernetes/manifests/etcd.yaml to /var/lib/etcd-restore
# then restart the kubelet on every node (systemctl restart kubelet), or pods can show stale status
```

## Node preparation (before kubeadm)

```bash
swapoff -a && sed -i '/ swap /d' /etc/fstab
printf 'overlay\nbr_netfilter\n' > /etc/modules-load.d/k8s.conf && modprobe overlay && modprobe br_netfilter
printf 'net.bridge.bridge-nf-call-iptables=1\nnet.bridge.bridge-nf-call-ip6tables=1\nnet.ipv4.ip_forward=1\n' > /etc/sysctl.d/k8s.conf && sysctl --system
# containerd: SystemdCgroup = true in /etc/containerd/config.toml
```

## Time strategy

- About 17 questions in 120 minutes is roughly **7 minutes each**. Skip anything that takes longer than 10 and come back to it.
- Use the exam's flag feature for questions you skip. Go back to them at the end.
- Partial credit counts, so do the parts you know.
