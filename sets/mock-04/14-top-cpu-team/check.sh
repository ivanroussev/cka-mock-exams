check "top team=data pod is data-lake/compactor" file_eq "$ANSWERS/data-top-pod.txt" "data-lake/compactor"
check "its busiest container is compact" file_eq "$ANSWERS/data-top-container.txt" "compact"
