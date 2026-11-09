Pod `analytics` in namespace `resize` needs more resources, but it must **not be recreated** (keep the same pod, same UID).

1. Resize the container `analytics` **in place** to a CPU request of `300m` and a CPU limit of `500m`.
2. Also raise its memory limit to `256Mi` (keep the memory request as it is).
3. Look at the container's `resizePolicy`, then write the container's **restart count** after both changes are applied to
   `{{ANSWERS}}/analytics-restarts.txt`.

The new values must be in effect on the running container, not just in the pod spec.
