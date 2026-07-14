#!/usr/bin/env bash

# --- Temperature (Tctl from k10temp) ---
temp=$(sensors -u k10temp-pci-00c3 2>/dev/null | awk '
  /^Tctl:/ { infield=1; next }
  infield && /temp[0-9]+_input/ { print $2; exit }
')
temp=${temp%.*} # strip decimal, keep integer part

# fallback in case Tctl label is missing on this board/BIOS
if [ -z "$temp" ]; then
  temp=$(sensors | grep -m1 'Tctl' | grep -oP '[\d.]+(?=°C)' | cut -d'.' -f1)
fi

# --- Utilization (delta over 200ms) ---
read -r _ u1 n1 s1 i1 w1 irq1 sirq1 _ </proc/stat
sleep 0.2
read -r _ u2 n2 s2 i2 w2 irq2 sirq2 _ </proc/stat

idle1=$i1
idle2=$i2
total1=$((u1 + n1 + s1 + i1 + w1 + irq1 + sirq1))
total2=$((u2 + n2 + s2 + i2 + w2 + irq2 + sirq2))

total_diff=$((total2 - total1))
idle_diff=$((idle2 - idle1))

if [ "$total_diff" -gt 0 ]; then
  util=$(((100 * (total_diff - idle_diff)) / total_diff))
else
  util=0
fi

class="normal"
if [ -n "$temp" ] && [ "$temp" -ge 85 ]; then
  class="critical"
elif [ -n "$temp" ] && [ "$temp" -ge 70 ]; then
  class="warning"
fi

printf '{"text": " %s°C", "tooltip": "CPU Utilization: %s%%", "class": "%s"}' \
  "${temp:-N/A}" "$util" "$class"
