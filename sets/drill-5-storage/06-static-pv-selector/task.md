Three PersistentVolumes `pv-red`, `pv-blue` and `pv-green` (StorageClass `manual`, 1Gi, `ReadWriteOnce`) only differ by their `team` label.

1. In namespace `teams`, create a PVC named `blue-claim` (class `manual`, 1Gi, `ReadWriteOnce`) that binds to the PV labelled
   `team=blue`. Use a **label selector** — don't name the PV in the claim.
2. Create a Pod `blue-app` in namespace `teams` (image `busybox:1.37`, command `sh -c 'echo hello > /work/hello.txt; sleep 3600'`)
   that mounts `blue-claim` at `/work` with **subPath** `blue-app`, so its files land in a `blue-app` sub-directory of the volume.
