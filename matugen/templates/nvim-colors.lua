return {

  -- color approach

  red            = "{{ colors.error.dark.hex }}",
  orange         = "{{ colors.secondary.dark.hex }}",
  green          = "{{ colors.tertiary.dark.hex }}",
  yellow         = "{{ colors.tertiary_fixed.dark.hex }}",
  blue           = "{{ colors.primary.dark.hex }}",
  magenta        = "{{ colors.secondary_container.dark.hex }}",
  cyan           = "{{ colors.tertiary_container.dark.hex }}",
  black          = "{{ colors.surface.dark.hex }}",
  bright_red     = "{{ colors.error_container.dark.hex }}",
  bright_orange  = "{{ colors.secondary_fixed_dim.dark.hex }}",
  bright_green   = "{{ colors.tertiary_fixed_dim.dark.hex }}",
  bright_yellow  = "{{ colors.tertiary_fixed.dark.hex }}",
  bright_blue    = "{{ colors.primary_fixed_dim.dark.hex }}",
  bright_magenta = "{{ colors.secondary_fixed.dark.hex }}",
  bright_cyan    = "{{ colors.tertiary_fixed.dark.hex }}",
  white          = "{{ colors.on_surface.dark.hex }}",
  gutter_fg      = "{{ colors.outline.dark.hex }}",
  nontext        = "{{ colors.on_surface_variant.dark.hex }}",

  -- element approach

  bg         = "{{ colors.surface_container_lowest.dark.hex }}",
  fg         = "{{ colors.on_surface.dark.hex }}",
  cursorline = "{{ colors.surface_container.dark.hex }}",
  selection  = "{{ colors.secondary_container.dark.hex }}",
  linenr     = "{{ colors.outline_variant.dark.hex }}",
  comment    = "{{ colors.on_surface_variant.dark.hex }}",

  -- Syntax
  keyword   = "{{ colors.primary.dark.hex }}",
  Function  = "{{ colors.primary_fixed.dark.hex }}",
  string    = "{{ colors.tertiary.dark.hex }}",
  constant  = "{{ colors.secondary.dark.hex }}",
  type      = "{{ colors.secondary_fixed.dark.hex }}",
  number    = "{{ colors.tertiary_fixed_dim.dark.hex }}",
  boolean   = "{{ colors.error.dark.hex }}",
  operator  = "{{ colors.outline.dark.hex }}",
  variable  = "{{ colors.on_surface.dark.hex }}",

  -- UI
  cursor     = "{{ colors.primary.dark.hex }}",
  visual     = "{{ colors.surface_variant.dark.hex }}",
  search     = "{{ colors.secondary_fixed_dim.dark.hex }}",
  statusline = "{{ colors.surface_container_highest.dark.hex }}",
  menu_bg    = "{{ colors.surface_container.dark.hex }}",
  menu_sel   = "{{ colors.primary_container.dark.hex }}",
  fold       = "{{ colors.surface_container_highest.dark.hex }}",
  split      = "{{ colors.outline_variant.dark.hex }}",

  -- Diagnostics
  diag_error = "{{ colors.error.dark.hex }}",
  diag_warn  = "{{ colors.tertiary.dark.hex }}",
  diag_info  = "{{ colors.secondary.dark.hex }}",
  diag_hint  = "{{ colors.primary_fixed_dim.dark.hex }}",
}
