Namespace `crunch`.

1. Pod `importer` keeps restarting. Find out why its container `loader` was last terminated. Write the **reason** (the single word
   Kubernetes reports) to `{{ANSWERS}}/importer-reason.txt` and the container's **exit code** to `{{ANSWERS}}/importer-exitcode.txt`.
   Don't change the pod.
2. Pod `cruncher` is CPU-throttled: `kubectl top` shows it pinned at its CPU limit. Without deleting or recreating the pod and
   **without restarting its container**, change its container `worker` to request `250m` CPU with a limit of `500m`.
   Leave its memory settings as they are.
