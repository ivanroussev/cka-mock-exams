Deployment `portal` in namespace `portal` loads all keys of ConfigMap `portal-config` as environment variables.

1. Create a Secret named `portal-db` in namespace `portal` from the env file `{{FILES}}/portal-db.env` (one key per line in the file).
2. Make the `portal` container get **only** the `DB_PASSWORD` key of that Secret, as the environment variable `PORTAL_DB_PASSWORD`.
   `DB_USER` must not be exposed to the container.
3. Change the key `THEME` in ConfigMap `portal-config` to `dark`.
4. Make sure every running `portal` pod sees `THEME=dark` and `PORTAL_DB_PASSWORD`. Don't delete the Deployment.
