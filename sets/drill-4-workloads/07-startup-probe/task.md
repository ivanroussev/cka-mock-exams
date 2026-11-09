The pods of Deployment `ledger-ui` in namespace `probes` keep restarting. The application takes about 40 seconds to start, and its
liveness probe kills it before it's up.

Fix it **without changing the liveness probe or the container command**:

1. Add a **startup probe** (HTTP GET `/` on port 80, every 5 seconds) that gives the application **at least 60 seconds** to start.
2. Add a **readiness probe** (HTTP GET `/` on port 80, every 5 seconds) so pods only receive traffic once nginx answers.
3. Both replicas must be Ready and stop restarting.
