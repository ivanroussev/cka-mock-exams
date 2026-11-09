# The scenario (cluster-1.36) already built the cluster; just add a workload so draining matters.
vm_kubectl create deployment web --image=nginx:1.27-alpine --replicas=2 >/dev/null 2>&1 || true
