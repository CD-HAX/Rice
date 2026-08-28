return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#121212",
        dark_bg    = "#0e0e0e",
        darker_bg  = "#090909",
        lighter_bg = "#2a2a2a",

        fg         = "#ffffff",
        dark_fg    = "#bfbfbf",
        light_fg   = "#ffffff",
        bright_fg  = "#ffffff",
        muted      = "#9e9e9e",

        red        = "#e54743",
        yellow     = "#979b4b",
        orange     = "#e9635f",
        green      = "#699b4b",
        cyan       = "#4b9b9b",
        blue       = "#5d7dc7",
        purple     = "#cd577c",
        brown      = "#8c3b39",

        bright_red    = "#ff665e",
        bright_yellow = "#b5bb54",
        bright_green  = "#7bbb54",
        bright_cyan   = "#54bbbb",
        bright_blue   = "#7f9ffe",
        bright_purple = "#fe75a3",

        accent               = "#5d7dc7",
        cursor               = "#ffffff",
        foreground           = "#ffffff",
        background           = "#121212",
        selection             = "#2a2a2a",
        selection_foreground = "#ffffff",
        selection_background = "#2a2a2a",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
