Deployment `collector` in namespace `ingest` writes its log to the file `/var/log/collector/app.log` inside container `app`.
Add a log-shipping sidecar to it:

1. Add a volume `logs` of type `emptyDir`, mounted at `/var/log/collector` in container `app`.
2. Add a **native sidecar** container (an init container that keeps running alongside the app) named `log-shipper`,
   image `busybox:1.37`, command `tail -F /var/log/collector/app.log`, with the same volume mounted at `/var/log/collector`.
3. Give `log-shipper` an environment variable `SHIP_TOKEN` taken from key `token` of the existing Secret `shipper-creds`.

`kubectl logs deploy/collector -c log-shipper` must then show the app's log lines.
