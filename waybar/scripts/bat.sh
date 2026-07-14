#!/bin/sh

<<<<<<< HEAD
device=$(upower -e | while read -r d; do
  info=$(upower -i "$d")
  echo "$info" | grep -qi "model:.*compx VXE" &&
    echo "$info" | grep -q "present:[[:space:]]*yes" &&
    echo "$info" | grep -q "state: " &&
=======
device=$(upower -e | while read -r d; do   
  info=$(upower -i "$d")
  echo "$info" | grep -qi "model:.*compx VXE" &&
    echo "$info" | grep -q "present:[[:space:]]*yes" &&
>>>>>>> d71483aefb697760a519ab4e7588fa31ba6d6520
    {
      echo "$d"
      break
    }
done) # Get device by checking through all devices and matching "battery" and then remove the space.

percent=$(upower -i "$device" | awk '/percentage:/ {    
    gsub("%", "")
    print $2
}') #Getting the battery percentage and removing whitespaces.

<<<<<<< HEAD
state=$(upower -i "$device" | awk '/state:/ {
  print $2 
}')

=======
>>>>>>> d71483aefb697760a519ab4e7588fa31ba6d6520
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

<<<<<<< HEAD
printf '{"text":"Compx VXE  %s  %s%%","class":"%s","state":"%s"} \n' \
  "$icon" "$percent" "$class" "$state"
=======
printf '{"text":"Compx VXE  %s  %s%%","class":"%s"}\n' \
  "$icon" "$percent" "$class"
>>>>>>> d71483aefb697760a519ab4e7588fa31ba6d6520
