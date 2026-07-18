return {

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "matugen",
    },
  },
  {
    dir = "~/.config/nvim/lua/matugen/",
    lazy = false,
    priority = 1000, -- Make sure it loads first
    config = function()
      require("matugen").setup()
    end,
  },
}
