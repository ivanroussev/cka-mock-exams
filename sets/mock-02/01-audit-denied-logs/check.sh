expected() { kubectl --context main -n compliance logs -l app=audit-relay --tail=-1 --max-log-requests=10 2>/dev/null | grep DENIED | sort; }
export -f expected
check "denied.log has every DENIED line of all 3 pods (and nothing else)" bash -c "
  e=\$(expected); [ \$(printf '%s\n' \"\$e\" | grep -c DENIED) -ge 6 ] || exit 1
  got=\$(grep -o 'DENIED.*' '$ANSWERS/denied.log' | sed 's/[[:space:]]*\$//' | sort)
  [ \"\$got\" = \"\$e\" ] && ! grep -q ALLOWED '$ANSWERS/denied.log'"
check "denied-count.txt has the right number" bash -c "file_eq '$ANSWERS/denied-count.txt' \"\$(expected | grep -c DENIED)\""
