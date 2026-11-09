# Self-contained: prepare the nodes first if question 1 wasn't solved.
node_exec cp1 "command -v kubeadm" >/dev/null 2>&1 && node_exec w1 "command -v kubeadm" >/dev/null 2>&1 \
  || source "$TASK_DIR/../01-prepare-nodes/solution.sh"
node_exec cp1 "kubeadm init --pod-network-cidr 10.244.0.0/16"
node_exec cp1 "mkdir -p /root/.kube && cp -f /etc/kubernetes/admin.conf /root/.kube/config && chown root:root /root/.kube/config"
wait_for 120 vm_kubectl get --raw /readyz
for i in 1 2 3 4 5; do
  vm_kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml && break; sleep 5
done
node_exec w1 "$(node_exec cp1 'kubeadm token create --print-join-command')"
wait_for 300 bash -c "[ \"\$(vm_kubectl get nodes --no-headers | awk '\$2==\"Ready\"' | wc -l | tr -d ' ')\" = 2 ]"
wait_for 180 bash -c "[ \"\$(vm_kubectl -n kube-flannel get ds kube-flannel-ds -o jsonpath='{.status.numberReady}')\" = 2 ]"
