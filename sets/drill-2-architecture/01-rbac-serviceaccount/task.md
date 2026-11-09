A CI system will deploy into namespace `ci-pipeline` using its own identity.

1. Create a ServiceAccount `deployer` in namespace `ci-pipeline`.
2. Create a Role `deploy-manager` in the same namespace that allows **only**:
   - `get`, `list`, `watch`, `create`, `update`, `patch` on `deployments`
   - `get`, `list` on `pods`
3. Bind the Role to the ServiceAccount with a RoleBinding named `deployer-binding`.

The ServiceAccount must not be able to do anything else (for example, delete Deployments or read Secrets).
