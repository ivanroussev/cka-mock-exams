metrics-server was installed in namespace `kube-system`, but `kubectl top` only answers with an error.

1. Find out why and fix metrics-server, so `kubectl top nodes` and `kubectl top pods` work.
   (The kubelets in this cluster use self-signed serving certificates.)
2. In namespace `render-farm`, find the pod using the most **CPU** and write its name to `{{ANSWERS}}/render-top-cpu.txt`.
