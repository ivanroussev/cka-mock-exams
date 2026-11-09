On node `cka-bare-worker` the **kubelet** no longer stays up since someone changed how the kubelet service is started.

Find the cause and fix it so the kubelet runs and also starts at boot. Work on the node (`ssh cka-bare-worker`).

*Cluster `bare` has no network plugin, so its nodes show NotReady anyway — that is expected and not part of this question.*
