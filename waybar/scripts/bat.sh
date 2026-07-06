#!/bin/sh

device=$(upower -e | while read -r d; do   
  info=$(upower -i "$d")
  echo "$info" | grep -qi "model:.*compx VXE" &&
    echo "$info" | grep -q "present:[[:space:]]*yes" &&
    {
      echo "$d"
      break
    }
done) # Get device by checking through all devices and matching "battery" and then remove the space.

percent=$(upower -i "$device" | awk '/percentage:/ {    
    gsub("%", "")
    print $2
}') #Getting the battery percentage and removing whitespaces.

if [ "$percent" -ge 95 ]; then
  icon=""
  class="full"
elif [ "$percent" -ge 75 ]; then
  icon=""
  class="high"
elif [ "$percent" -ge 50 ]; then
  icon=""
  class="medium"
elif [ "$percent" -le 30 ]; then
  icon=""
  class="low"
else
  icon=""
  class="critical"
fi

printf '{"text":"Compx VXE  %s  %s%%","class":"%s"}\n' \
  "$icon" "$percent" "$class"
