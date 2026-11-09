After someone changed the control-plane configuration on `cka-bare-control-plane`, every `kubectl` command against
cluster `bare` fails.

1. Fix the cluster so the API server answers again.
2. Write the name of the kube-apiserver **flag** that was wrong (e.g. `--some-flag`) to `{{ANSWERS}}/apiserver-flag.txt`.

*Cluster `bare` has no network plugin, so its nodes show NotReady — that is expected and not part of this question.*
