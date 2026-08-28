#!/bin/bash

# ==============================================================================
# AETHER UNIVERSAL THEME GENERATOR
# ==============================================================================

AETHER_FILE="$HOME/.config/quickshell/services/aether-colors.conf"
if [[ ! -f "$AETHER_FILE" ]]; then
    exit 0
fi

# Load variables from Aether
source "$AETHER_FILE"

# ==============================================================================
# 1. Update Quickshell
# ==============================================================================
update_quickshell() {
    THEME_FILE="$HOME/.config/quickshell/services/Theme.qml"
    if [[ ! -f "$THEME_FILE" ]]; then return; fi

    while IFS='=' read -r key val; do
        key=$(echo "$key" | xargs)
        val=$(echo "$val" | xargs | tr -d '"'\')
        if grep -q "property color $key:" "$THEME_FILE"; then
            sed -i -E "s/(property color $key:[[:space:]]*)\"[^\"]*\"/\1\"$val\"/" "$THEME_FILE"
        fi
    done < "$AETHER_FILE"

    declare -A KEY_MAP=(
        ["dark_background"]="darkBackground"
        ["darker_background"]="darkerBackground"
        ["lighter_background"]="lighterBackground"
        ["dark_foreground"]="darkForeground"
        ["light_foreground"]="lightForeground"
        ["bright_foreground"]="brightForeground"
    )

    while IFS='=' read -r key val; do
        key=$(echo "$key" | xargs)
        val=$(echo "$val" | xargs | tr -d '"'\')
        if [[ -v KEY_MAP["$key"] ]]; then
            mapped_key=${KEY_MAP["$key"]}
            if grep -q "property color $mapped_key:" "$THEME_FILE"; then
                sed -i -E "s/(property color $mapped_key:[[:space:]]*)\"[^\"]*\"/\1\"$val\"/" "$THEME_FILE"
            fi
        fi
    done < "$AETHER_FILE"
}

# ==============================================================================
# 2. Update Kitty
# ==============================================================================
update_kitty() {
    KITTY_THEME="$HOME/.config/kitty/kitty-aether.conf"

    cat > "$KITTY_THEME" <<EOF
# Aether dynamically generated theme for Kitty
background $background
foreground $foreground
selection_background $selection
selection_foreground $bright_foreground
url_color $accent
cursor $accent

# Black
color0 $darker_background
color8 $surface

# Red
color1 $red
color9 $red

# Green
color2 $green
color10 $green

# Yellow
color3 $yellow
color11 $yellow

# Blue
color4 $blue
color12 $blue

# Magenta
color5 $magenta
color13 $magenta

# Cyan
color6 $cyan
color14 $cyan

# White
color7 $foreground
color15 $bright_foreground
EOF

    # Send signal to reload kitty natively
    killall -USR1 kitty 2>/dev/null
}

# ==============================================================================
# 3. Update Neovim
# ==============================================================================
update_neovim() {
    PALETTE_LUA="$HOME/.config/nvim/lua/matugen/palette.lua"

    cat > "$PALETTE_LUA" <<EOF
return {

  -- color approach

  red            = "$red",
  orange         = "$orange",
  green          = "$green",
  yellow         = "$yellow",
  blue           = "$blue",
  magenta        = "$magenta",
  cyan           = "$cyan",
  black          = "$darker_background",
  bright_red     = "$red",
  bright_orange  = "$orange",
  bright_green   = "$green",
  bright_yellow  = "$yellow",
  bright_blue    = "$blue",
  bright_magenta = "$magenta",
  bright_cyan    = "$cyan",
  white          = "$bright_foreground",
  gutter_fg      = "$surface",
  nontext        = "$overlay",

  -- element approach

  bg         = "$background",
  fg         = "$foreground",
  cursorline = "$selection",
  selection  = "$selection",
  linenr     = "$surface",
  comment    = "$overlay",

  -- Syntax
  keyword   = "$red",
  Function  = "$blue",
  string    = "$green",
  constant  = "$orange",
  type      = "$yellow",
  number    = "$magenta",
  boolean   = "$red",
  operator  = "$overlay",
  variable  = "$foreground",

  -- UI
  cursor     = "$accent",
  visual     = "$selection",
  search     = "$yellow",
  statusline = "$darker_background",
  menu_bg    = "$darker_background",
  menu_sel   = "$selection",
  fold       = "$surface",
  split      = "$surface",

  -- Diagnostics
  diag_error = "$red",
  diag_warn  = "$yellow",
  diag_info  = "$blue",
  diag_hint  = "$cyan",
}
EOF

    # Send signal to reload neovim natively
    killall -USR1 nvim 2>/dev/null
}

# Execute all functions
update_quickshell
update_kitty
update_neovim
