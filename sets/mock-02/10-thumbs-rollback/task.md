The latest rollout of Deployment `thumbs` in namespace `gallery` broke it: the new pods crash.

1. Find the revision whose change cause is `enable gold tier` and write its number to `{{ANSWERS}}/thumbs-good-revision.txt`.
2. Roll the Deployment back to **that** revision.
3. Change the rollout strategy so future updates never drop below the desired replica count and add at most one extra pod at a time
   (`maxUnavailable: 0`, `maxSurge: 1`).

All 3 replicas must be running the restored version.
