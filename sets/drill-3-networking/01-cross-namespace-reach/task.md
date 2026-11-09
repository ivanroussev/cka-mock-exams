Context: `main`

Namespace `ledger` runs Deployment `ledger-api` behind Service `ledger-api` (port 80). Pod `invoicer` in namespace `billing`
is supposed to call it using the URL in its environment variable `LEDGER_URL`, but every request fails.

1. Write the Pod IP addresses of **all** Pods of Deployment `ledger-api` to `{{ANSWERS}}/ledger-ips.txt`, one IP per line.
2. Fix Pod `invoicer` so that `curl $LEDGER_URL`, run inside it, returns the ledger page. `LEDGER_URL` must use the Service's
   **fully qualified** domain name. Keep the Pod's name, namespace, image and command.
