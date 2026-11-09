kubectl --context main -n compliance logs -l app=audit-relay --tail=-1 --prefix | grep DENIED > "$ANSWERS/denied.log"
grep -c DENIED "$ANSWERS/denied.log" > "$ANSWERS/denied-count.txt"
