The pods of Deployment `frontend` in namespace `storefront` log `could not resolve catalog` and never reach the catalog Service
(`catalog` in namespace `inventory`, port 80). Other pods in the cluster resolve Service names fine.

1. Fix `frontend` so its pods use the **cluster DNS** again.
2. The application calls the short name `http://catalog`. Without changing the application's command, make that short name resolve to
   Service `catalog` in namespace `inventory` by adding the search domain `inventory.svc.cluster.local` through the pod's DNS configuration.
3. Write the ClusterIP of the cluster DNS Service to `{{ANSWERS}}/cluster-dns-ip.txt`.
