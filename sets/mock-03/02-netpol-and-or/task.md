In namespace `payments`, NetworkPolicy `default-deny-ingress` blocks all ingress traffic, and NetworkPolicy `ledger-ingress` is meant to open
the `ledger` pods (Service `ledger`, port 80) to exactly two kinds of clients:

- pods labelled `app=prometheus` **in namespace `monitoring`**, and
- pods labelled `role=api` **in namespace `payments`**.

Both may only use TCP port 80. A security review found that other pods can reach the ledger, while the API pods can't.

Fix `ledger-ingress` (keep its name) so it allows exactly this. Don't modify or delete `default-deny-ingress`, and don't change any pod labels.
