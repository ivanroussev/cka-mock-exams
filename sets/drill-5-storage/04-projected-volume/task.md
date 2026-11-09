In namespace `webcfg`, create a Pod named `portal` (image `nginx:1.27-alpine`) with **one** volume named `bundle`,
mounted read-only at `/etc/portal`, that combines:

- key `site.conf` of ConfigMap `site-config` → file `/etc/portal/site.conf`
- key `token` of Secret `api-token` → file `/etc/portal/auth/token`

No other files from the ConfigMap should appear in `/etc/portal`.
