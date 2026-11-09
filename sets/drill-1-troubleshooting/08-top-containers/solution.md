```bash
kubectl top pod collector -n telemetry --containers        # POD  NAME  CPU(cores)  MEMORY(bytes)
echo parser > {{ANSWERS}}/telemetry-cpu.txt
kubectl top pod -n telemetry -l tier=buffer --sort-by=memory
echo buffer-2 > {{ANSWERS}}/telemetry-mem.txt
```
**Pitfalls:** without `--containers` you only get the pod total. Without `-l tier=buffer` the biggest pod is `spool`,
which isn't in the asked-for group. `kubectl top` shows current usage, not requests/limits.
