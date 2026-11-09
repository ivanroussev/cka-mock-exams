More workers will join the cluster from question 2 later today. The token from `kubeadm init` should not be handed out.

On `cp1`, create a **new** bootstrap token that expires after **2 hours**, and write the complete `kubeadm join` command
that uses it (including the CA certificate hash) to `/root/join-command.txt` on `cp1`.
