Namespace `billing-app`, Deployment `billing` (container `app`).

1. Create a ConfigMap `billing-config` that contains the file `{{FILES}}/billing.properties` under the key `billing.properties`
   and the literal key `LOG_LEVEL` with value `debug`.
2. Create a Secret `billing-db` with the keys `DB_USER=billing` and `DB_PASSWORD=S3cure!pass`. The Secret must be **immutable**.
3. Change the Deployment so that its container
   - gets the environment variable `LOG_LEVEL` from the ConfigMap key of the same name,
   - gets **all** keys of Secret `billing-db` as environment variables,
   - sees the properties file at `/etc/billing/billing.properties` — and only that key of the ConfigMap in `/etc/billing`.
