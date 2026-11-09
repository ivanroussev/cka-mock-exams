latest() { node_exec cp1 "apt-cache madison kubeadm 2>/dev/null | awk '{print \$3}' | grep '^1\.37\.' | sort -V | tail -1 | cut -d- -f1"; }
api_latest() { local v; v="$(latest)"; [ -n "$v" ] && vm_kubectl version -o json | grep -q "\"gitVersion\": \"v$v\""; }
kubelet_cp1() { vm_kubectl get node cp1 -o jsonpath='{.status.nodeInfo.kubeletVersion}' | grep -q '^v1\.37\.'; }
tools_cp1()  { node_exec cp1 "kubeadm version -o short | grep -q '^v1\.37\.' && kubectl version --client -o json | grep -q '\"minor\": \"37\"'"; }
w1_stays()   { vm_kubectl get node w1 -o jsonpath='{.status.nodeInfo.kubeletVersion}' | grep -q '^v1\.36\.' &&
               node_exec w1 "kubelet --version | grep -q ' v1\.36\.'"; }
cp1_ok()     { [ "$(vm_kubectl get node cp1 --no-headers | awk '{print $2}')" = Ready ]; }   # cordoned shows Ready,SchedulingDisabled

check "control plane (API server) runs the latest v1.37 patch" api_latest
check "kubelet on cp1 is v1.37" kubelet_cp1
check "kubeadm and kubectl on cp1 are v1.37" tools_cp1
check "w1 is still on kubelet v1.36" w1_stays
check "cp1 is Ready and uncordoned" cp1_ok
