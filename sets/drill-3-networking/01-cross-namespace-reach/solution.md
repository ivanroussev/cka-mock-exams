```bash
kubectl config use-context main
kubectl -n ledger get pods -l app=ledger-api -o wide            # IP column
kubectl -n ledger get pods -l app=ledger-api \
  -o jsonpath='{range .items[*]}{.status.podIP}{"\n"}{end}' > {{ANSWERS}}/ledger-ips.txt

kubectl -n billing exec invoicer -- sh -c 'echo $LEDGER_URL; curl -s -m 5 $LEDGER_URL'   # "Could not resolve host"
kubectl -n billing exec invoicer -- cat /etc/resolv.conf     # search billing.svc.cluster.local … → short name looks in billing

kubectl -n billing get pod invoicer -o yaml > invoicer.yaml
# edit: value: http://ledger-api.ledger.svc.cluster.local:80
kubectl replace --force -f invoicer.yaml                      # env of a running Pod is immutable → delete + recreate
kubectl -n billing exec invoicer -- sh -c 'curl -s $LEDGER_URL'
```
**Pitfall:** a short Service name (`ledger-api`) only resolves inside the *same* namespace, because the Pod's `search` list starts with
its own namespace. Across namespaces use `<svc>.<ns>` or the full `<svc>.<ns>.svc.cluster.local`.
Most Pod spec fields (env included) are immutable — `kubectl replace --force` is the fastest way to recreate a bare Pod.
