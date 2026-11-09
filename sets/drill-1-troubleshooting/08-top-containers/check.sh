check "busiest container of collector" file_eq "$ANSWERS/telemetry-cpu.txt" "parser"
check "tier=buffer pod using most memory" file_eq "$ANSWERS/telemetry-mem.txt" "buffer-2"
