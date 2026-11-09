kubectl --context main -n portal create secret generic portal-db --from-env-file="$FILES/portal-db.env"
kubectl --context main -n portal patch cm portal-config -p '{"data":{"THEME":"dark"}}'
kubectl --context main -n portal set env deploy/portal --from=secret/portal-db --keys=DB_PASSWORD --prefix=PORTAL_
kubectl --context main -n portal rollout status deploy/portal --timeout=120s
wait_for 60 bash -c '[ "$(kubectl --context main -n portal get pods -l app=portal --no-headers | wc -l | tr -d " ")" = 2 ]'
