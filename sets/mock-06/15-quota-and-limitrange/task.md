Namespace `team-red` has a ResourceQuota `team-red-quota`. Deployment `worker` (4 replicas) was created after it, but none of its pods exist.

1. Find out why, and fix it **without changing the Deployment or the quota**: create a LimitRange `team-red-defaults` in `team-red` so that every
   container that doesn't set them gets
   - default requests: `cpu: 100m`, `memory: 128Mi`;
   - default limit: `memory: 256Mi`;
   - and no container in the namespace may ever have a memory limit above `512Mi`.
2. When all 4 `worker` pods run, write the quota's current usage of `requests.memory` (exactly as shown in the quota's status, e.g. `384Mi`)
   to `{{ANSWERS}}/quota-used.txt`.
