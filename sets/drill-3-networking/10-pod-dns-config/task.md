Context: `main`

In namespace `dns-lab`:

1. Pod `lookup` can't resolve any Service name. Fix it so that it uses the cluster's DNS like a normal Pod does, and additionally set
   the resolver option `ndots` to `2` for this Pod. Keep the Pod's name, image and command.
2. Write the fully qualified domain name of Service `records` (namespace `dns-lab`) to `{{ANSWERS}}/records-fqdn.txt`.
3. Write the DNS name that resolves to the IP of Pod `cache` (namespace `dns-lab`) — the Pod A record that CoreDNS serves under
   the cluster domain — to `{{ANSWERS}}/cache-pod-dns.txt`.
