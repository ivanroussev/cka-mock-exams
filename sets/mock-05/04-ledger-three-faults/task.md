In namespace `ledger`, Deployment `teller` calls the `accounts` service at `http://accounts:8080` every 5 seconds and logs the result.
It has never worked.

Find and fix **every** problem so that `teller` gets the response from `accounts`. Rules:

- `teller` must keep using the URL `http://accounts:8080` and Service `accounts` must keep listening on port `8080`.
- The NetworkPolicy `default-deny-all` must stay exactly as it is, and no other pod in the namespace may gain access to `accounts`.
  You may change the other NetworkPolicies.
