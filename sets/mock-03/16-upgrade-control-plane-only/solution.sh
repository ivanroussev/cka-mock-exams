node_exec cp1 'sed -i "s#/v1.36/#/v1.37/#" /etc/apt/sources.list.d/kubernetes.list
  curl -fsSL --retry 5 --retry-all-errors https://pkgs.k8s.io/core:/stable:/v1.37/deb/Release.key | gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  apt-get update -q'
V=$(node_exec cp1 "apt-cache madison kubeadm | awk '{print \$3}' | grep '^1.37' | sort -V | tail -1")
node_exec cp1 "apt-mark unhold kubeadm && apt-get install -y -q kubeadm=$V && apt-mark hold kubeadm"
node_exec cp1 "kubeadm upgrade apply -y v${V%%-*}"
vm_kubectl drain cp1 --ignore-daemonsets --delete-emptydir-data
node_exec cp1 "apt-mark unhold kubelet kubectl && apt-get install -y -q kubelet=$V kubectl=$V && apt-mark hold kubelet kubectl && systemctl daemon-reload && systemctl restart kubelet"
wait_for 120 vm_kubectl get --raw /readyz
vm_kubectl uncordon cp1
wait_for 180 bash -c "vm_kubectl get node cp1 --no-headers | awk '{print \$2}' | grep -qx Ready"
