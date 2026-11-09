echo ledger > "$ANSWERS/billing-container.txt"
wait_for 60 bash -c "kubectl --context main -n finance logs billing -c ledger --previous | grep FATAL > '$ANSWERS/billing-fatal.txt'"
