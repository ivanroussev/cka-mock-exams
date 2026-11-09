In namespace `docs`:

1. Create an **immutable** ConfigMap `docs-site` with two keys: `index.html` taken from the file `{{FILES}}/index.html`,
   and `release` with the literal value `3`.
2. Create a Secret `docs-auth` with the key `token` and the value `tk-7f3a91`.
3. Create a Pod `docs` with image `nginx:1.27-alpine` that:
   - mounts **only** the `index.html` key of `docs-site` as `/usr/share/nginx/html/index.html` (the `release` key must not show up in that directory);
   - mounts Secret `docs-auth` **read-only** at `/etc/docs-auth`, with file permissions `0400`.
