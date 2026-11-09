Deployment `notifier` in namespace `alerts` is in `CrashLoopBackOff`.

1. Write the `FATAL` line the container prints before it exits **right now** (before you change anything) to `{{ANSWERS}}/notifier-fatal.txt`.
2. Fix the Deployment so its pod runs and stays running. The application's settings already exist in the namespace:
   - the SMTP password must come from Secret `smtp-credentials` (env var `SMTP_PASSWORD`) — don't put the password itself in the Deployment;
   - **every** key of ConfigMap `notifier-config` must be exposed to the container as an environment variable of the same name.

Don't modify the Secret or the ConfigMap.
