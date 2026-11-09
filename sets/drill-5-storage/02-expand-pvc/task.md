In namespace `reports`, PVC `report-data` (1Gi) is used by pod `report-writer` and is running out of space.

Increase the PVC's requested size to **2Gi**. Change whatever is needed on the storage side to allow it, but don't delete or
recreate the PVC or the pod.

*(The local-path provisioner in this practice cluster can't actually grow volumes, so the PVC's status capacity will stay
at 1Gi. Graded is the request.)*
