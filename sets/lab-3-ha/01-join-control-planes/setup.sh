# The ha scenario: haproxy on lb:6443 → cp1–3, cp1 initialised with --control-plane-endpoint lb:6443 --upload-certs,
# w1 joined, cp2 and cp3 prepared but not joined.
vm_kubectl get nodes >/dev/null
