In namespace `sync`, the pods of Deployment `ledger-sync` have been `Pending` since a colleague "tidied up" the control-plane manifests
on `cka-alt-control-plane`. `kubectl describe` shows no scheduling events for them.

Fix the cluster so both `ledger-sync` pods get scheduled and run. Don't change the Deployment.
Write the name of the **volume** (as named in the broken static pod manifest) that was misconfigured to `{{ANSWERS}}/scheduler-volume.txt`.
