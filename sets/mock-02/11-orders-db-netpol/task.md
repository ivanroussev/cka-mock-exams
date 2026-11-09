Namespace `data` already has a NetworkPolicy `deny-all-ingress`. The database pods there (label `app=orders-db`) listen on TCP port **5432**.

Create a NetworkPolicy `allow-orders-api` in namespace `data` that lets traffic reach the `app=orders-db` pods on port 5432
**only** from pods that are labelled `app=orders-api` **and** run in a namespace labelled `team=orders`.

Don't modify or delete `deny-all-ingress`. Pods in namespace `orders` are labelled correctly already; the namespace itself is not.
