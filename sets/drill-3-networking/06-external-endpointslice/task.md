Context: `main`

A legacy container registry runs **outside** the cluster. Its IP address is in `{{FILES}}/legacy-backend.txt`; it listens on TCP port **5000**.

In namespace `legacy`, make it reachable for Pods as `http://legacy-registry.legacy` (port 80):

1. Create a Service named `legacy-registry` with port **80**, target port **5000**, and **no selector**.
2. Create an EndpointSlice named `legacy-registry-1` that connects the Service to the external address.

Test: `curl http://legacy-registry.legacy/v2/` from a Pod returns `{}`.
