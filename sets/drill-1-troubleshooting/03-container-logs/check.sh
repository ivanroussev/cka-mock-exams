check "container name is ledger" file_eq "$ANSWERS/billing-container.txt" "ledger"
# The FATAL line from any recent run is accepted; it must be a real line the container printed.
check "FATAL line saved" bash -c "grep -q 'FATAL ledger: cannot open /data/ledger.db (code L-' '$ANSWERS/billing-fatal.txt' && [ \$(wc -l < '$ANSWERS/billing-fatal.txt') -le 2 ]"
