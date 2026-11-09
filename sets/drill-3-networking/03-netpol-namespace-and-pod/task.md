Context: `main`

In namespace `inventory`, the Pods of Deployment `stock-api` listen on TCP ports **80** and **9090** (Service `stock-api` exposes both).

They must accept incoming traffic **only** from Pods labelled `role=checkout` that run in a namespace labelled `team=shop`,
and **only on port 80**. Everything else that tries to reach them must be blocked.

A colleague already created NetworkPolicy `stock-ingress` in namespace `inventory` for this, but it lets far too much traffic through.
Fix `stock-ingress` (keep its name) so it implements the rule above. Don't modify any namespace or Pod labels.
