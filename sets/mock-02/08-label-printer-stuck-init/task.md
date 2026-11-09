In namespace `shipping`, the pods of Deployment `label-printer` never start; they stay in an `Init` state.
The database they need, Deployment `label-db`, is running fine.

1. Write the name of the container that is blocking the start-up to `{{ANSWERS}}/label-printer-blocker.txt`.
2. Fix the problem **without changing Deployment `label-printer` or `label-db`**, so that all `label-printer` pods become Ready.
