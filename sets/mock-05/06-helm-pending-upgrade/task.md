The Helm release `inventory` in namespace `inv` was installed from the chart in `{{FILES}}/inventory`.
An upgrade was interrupted, and now every `helm upgrade` fails with *"another operation (install/upgrade/rollback) is in progress"*.

1. Get the release out of its stuck state **without uninstalling it** (its revision history must be kept).
2. Then upgrade it with the chart in `{{FILES}}/inventory` so that it runs **3 replicas** of image tag **`1.28-alpine`**
   (set these as release values, not by editing the Deployment).

The release must end up in status `deployed` with all 3 pods ready.
