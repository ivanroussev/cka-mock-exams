After a colleague "tuned" the kubelet on node `cka-alt-worker` this morning, the node went **NotReady**.

Fix the node so that it is `Ready` again and stays that way after a reboot. The kubelet must use the configuration file kubeadm wrote,
`/var/lib/kubelet/config.yaml`. Don't touch that file.
