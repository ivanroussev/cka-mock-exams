In namespace `kv`:

1. Create a headless Service `kv` that selects pods labelled `app=kv` on port `6379`.
2. Create a StatefulSet `kv` with **3** replicas of image `redis:7-alpine` (container port `6379`, pod label `app=kv`) that uses the
   Service `kv` for its pod DNS names.
3. Create a PodDisruptionBudget `kv-pdb` that makes sure at least **2** `kv` pods stay available during voluntary disruptions (e.g. node drains).
4. Write the fully qualified DNS name of the **second** replica of the StatefulSet to `{{ANSWERS}}/kv-replica.txt`.
