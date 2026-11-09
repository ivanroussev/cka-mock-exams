live_pods() { kubectl --context main -n portal get pods -l app=portal -o go-template='{{range .items}}{{if not .metadata.deletionTimestamp}}{{.metadata.name}} {{end}}{{end}}'; }
export -f live_pods
check "Secret portal-db has both keys from the env file" bash -c "
  [ \"\$(kubectl --context main -n portal get secret portal-db -o jsonpath='{.data.DB_USER}' | base64 -d)\" = portal_app ] &&
  [ \"\$(kubectl --context main -n portal get secret portal-db -o jsonpath='{.data.DB_PASSWORD}' | base64 -d)\" = Xk9-portal-2026 ]"
check "ConfigMap portal-config has THEME=dark" field_eq main "cm/portal-config -n portal" '{.data.THEME}' dark
check "PORTAL_DB_PASSWORD comes from key DB_PASSWORD of Secret portal-db" field_eq main "deploy/portal -n portal" \
  '{.spec.template.spec.containers[0].env[?(@.name=="PORTAL_DB_PASSWORD")].valueFrom.secretKeyRef.name}/{.spec.template.spec.containers[0].env[?(@.name=="PORTAL_DB_PASSWORD")].valueFrom.secretKeyRef.key}' portal-db/DB_PASSWORD
check "every running pod sees THEME=dark and the password, but not DB_USER" bash -c "
  n=0; for p in \$(live_pods); do
    e=\$(kubectl --context main -n portal exec \$p -- env) || exit 1
    echo \"\$e\" | grep -qx 'THEME=dark' && echo \"\$e\" | grep -qx 'PORTAL_DB_PASSWORD=Xk9-portal-2026' || exit 1
    echo \"\$e\" | grep -q '^DB_USER=' && exit 1
    n=\$((n+1)); done; [ \$n -eq 2 ]"
