A CI job runs as ServiceAccount `deploy-bot` in namespace `release`. It must be able to **resize** Deployments in that namespace, and nothing more.

1. Create a Role `deployment-scaler` in namespace `release` that allows exactly:
   - `get`, `list` and `watch` on Deployments,
   - `get`, `update` and `patch` on the **scale** subresource of Deployments.
2. Bind it to ServiceAccount `deploy-bot` with a RoleBinding `deploy-bot-scaler`.

`deploy-bot` must **not** be able to change a Deployment's spec directly (e.g. update its image), delete Deployments, or read Secrets.
