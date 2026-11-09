In namespace `crm`, the pods of Deployment `crm-frontend` can't reach the backend: `wget http://crm-db` inside them fails with `bad address 'crm-db'`.
Service `crm-db` and its pods are healthy.

1. Fix Deployment `crm-frontend` so that its pods resolve cluster Service names again (don't change its image or command).
   `http://crm-db` must work from inside its pods.
2. Write the fully qualified domain name of Service `crm-db` to `{{ANSWERS}}/crm-db-fqdn.txt`.
