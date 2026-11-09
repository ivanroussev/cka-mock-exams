The company's internal DNS zone `corp.internal` is served by the DNS server behind Service `corp-dns` in namespace `corp-dns`.
Pods can't resolve names like `ledger.corp.internal` yet.

1. Configure the cluster DNS (CoreDNS in `kube-system`) so that queries for `corp.internal` (and its subdomains) are forwarded to that DNS server.
   Resolution of cluster names and of everything else must keep working as before.
2. Once it works, write the IP address that `vault.corp.internal` resolves to into `{{ANSWERS}}/vault-ip.txt`.
