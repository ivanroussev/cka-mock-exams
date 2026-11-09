In namespace `scratch`, create a Pod named `ram-share` with:

- a volume named `cache`: an `emptyDir` backed by **memory** (tmpfs), limited to **64Mi**
- container `writer`, image `busybox:1.37`, command `sh -c 'echo ready > /cache/status; sleep 3600'`, mounting `cache` at `/cache`
- container `reader`, image `busybox:1.37`, command `sleep 3600`, mounting `cache` **read-only** at `/data`
