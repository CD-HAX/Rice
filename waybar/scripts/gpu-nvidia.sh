#!/usr/bin/env bash

data=$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu,memory.used,memory.total \
  --format=csv,noheader,nounits)

temp=$(echo "$data" | cut -d',' -f1 | tr -d ' ')
util=$(echo "$data" | cut -d',' -f2 | tr -d ' ')
mem_used=$(echo "$data" | cut -d',' -f3 | tr -d ' ')
mem_total=$(echo "$data" | cut -d',' -f4 | tr -d ' ')

# alert class if temp is high, useful for styling
class="normal"
if [ "$temp" -ge 80 ]; then
  class="critical"
elif [ "$temp" -ge 65 ]; then
  class="warning"
fi

printf '{"text": "%s°C", "tooltip": "GPU Utilization: %s%%\\nVRAM: %s MiB / %s MiB", "class": "%s"}' \
  "$temp" "$util" "$mem_used" "$mem_total" "$class"
