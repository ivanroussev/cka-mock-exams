check "top container is etl-transform/reducer" file_eq "$ANSWERS/top-container.txt" "etl-transform/reducer"
check "node of etl-transform" bash -c "[ -n \"\$(tr -d '[:space:]' < '$ANSWERS/top-container-node.txt')\" ] && file_eq '$ANSWERS/top-container-node.txt' \"\$(kubectl --context main -n analytics get pod etl-transform -o jsonpath='{.spec.nodeName}')\""
