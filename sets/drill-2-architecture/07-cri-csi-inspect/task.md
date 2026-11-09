Collect some facts about the extension interfaces of cluster `main`. Write each answer as a single line.

1. The CRI endpoint (socket) that the kubelet on node `cka-main-worker2` is configured to use, e.g. `unix:///path/to/x.sock`
   → `{{ANSWERS}}/cri-endpoint.txt`
2. The container runtime's name and version as reported by `crictl` on that node, in the form `<RuntimeName> <RuntimeVersion>`
   → `{{ANSWERS}}/cri-version.txt`
3. The provisioner used by StorageClass `archive` → `{{ANSWERS}}/archive-provisioner.txt`
4. The value of `attachRequired` (`true` or `false`) of the CSIDriver object that serves StorageClass `archive`
   → `{{ANSWERS}}/archive-attach.txt`
