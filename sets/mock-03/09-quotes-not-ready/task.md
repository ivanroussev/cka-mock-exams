In namespace `quotes`, requests to `http://quotes.quotes` (Service `quotes`, port 80) get no answer, although both pods of Deployment `quotes`
show `Running`.

Fix it so the Service sends traffic to **both** pods and `http://quotes.quotes/healthz` returns `ok`.
The pods must keep an HTTP readiness probe on path `/healthz`, and the Service must keep port 80.
