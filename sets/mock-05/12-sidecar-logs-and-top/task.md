Namespace `audit`.

1. Deployment `ledger-writer` writes its log only to the file `/var/log/app/app.log` (volume `logs`), so `kubectl logs` shows nothing.
   Add a **native sidecar** container named `log-shipper` (image `busybox:1.37`) that starts before `app`, keeps running alongside it,
   and streams the whole file (from its first line) to its own stdout, e.g. with `tail -n +1 -F`.
2. From the logs of `log-shipper`, write **all lines containing `ERROR`** (and nothing else) to `{{ANSWERS}}/errors.txt`.
3. Pod `analytics` has three containers. Using the metrics API, find the container that uses the most CPU and write its name to
   `{{ANSWERS}}/hungry-container.txt`.
