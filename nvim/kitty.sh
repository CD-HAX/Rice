#!/bin/bash

#Check if the terminal is Kitty using the KITTY_PID env-variable

if [[ -n "$KITTY_PID" ]]; then
  kitty @ set-spacing padding=0 margin=0
  nvim "$@"
  kitty @ set-spacing padding=default margin=default
else
  nvim "$@"
fi
