# The VM lab

Five Ubuntu 24.04 VMs on Lima, on a shared private network. Every VM knows the others by name (through `/etc/hosts`).

| VM | Role | Memory |
|---|---|---|
| `lb` | HAProxy for the HA control plane (`lb:6443`) | 1 GB |
| `cp1`, `cp2`, `cp3` | Control-plane nodes | 2 GB each |
| `w1` | Worker | 2 GB |

`./cka start` resets the VMs automatically for any set that needs them, which adds 2–4 minutes. You can also drive them by hand:

```bash
./cka vm scenario cluster-1.37   # reset into a starting state (see below)
./cka ssh cp1                    # root shell; k=kubectl, KUBECONFIG is already set
./cka vm status
./cka vm down                    # stop them (frees ~9 GB of RAM)
./cka vm delete                  # remove them completely
```

## Starting states

| Scenario | State |
|---|---|
| `blank` | Fresh Ubuntu, swap on, nothing installed. Practise everything from node prep onwards. |
| `prepared` | containerd and kubeadm/kubelet/kubectl 1.37 installed on cp1–3 and w1. Practise `kubeadm init` and `join`. |
| `cluster-1.36` | A working cp1 + w1 cluster on v1.36 (flannel). Practise upgrades. |
| `cluster-1.37` | The same on v1.37. Practise etcd backup and restore, certificates and kubelet fixes. |
| `ha` | HAProxy on lb, cp1 initialised behind `lb:6443`, w1 joined, cp2 and cp3 ready to join as control planes. |

Pod network CIDR is `10.244.0.0/16` (flannel: `kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml`).
