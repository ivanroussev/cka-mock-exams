Job `nightly-export` in namespace `jobs` never finishes: its log-shipping container `shipper` runs forever next to the
`export` container, so the pod never completes.

Replace the Job (same name and namespace) so that:

1. `shipper` runs as a **native sidecar** (it starts before `export`, keeps running while `export` runs, and doesn't keep the Job from completing).
   Keep both containers' images, commands and the shared `emptyDir` volume as they are.
2. The pod is never restarted in place (`restartPolicy: Never`) and the Job gives up after **2** retries.
3. The Job completes successfully, and the logs of `shipper` contain the line `exported batch 5`.
