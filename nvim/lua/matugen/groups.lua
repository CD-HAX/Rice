local M = {}

local colors = require("matugen.palette")

M.setup = function()
  return {

    -- Core UI
    Normal = { fg = colors.fg, bg = colors.bg },
    Comment = { fg = colors.comment, italic = true },
    CursorLine = { bg = colors.cursorline },
    CursorColumn = { bg = colors.cursorcolumn },
    Cursor = { bg = colors.cursor },
    LineNr = { fg = colors.linenr },
    CursorLineNr = { fg = colors.cursorlinenr },
    Visual = { bg = colors.visual },
    Search = { fg = colors.fg, bg = colors.search },
    StatusLine = { fg = colors.fg, bg = colors.statusline },
    IncSearch = { fg = colors.fg, bg = colors.incsearch },
    VertSplit = { fg = colors.vertsplit },
    Folded = { fg = colors.comment, bg = colors.fold },
    Pmenu = { fg = colors.fg, bg = colors.pmenu },
    PmenuSel = { fg = colors.fg, bg = colors.pmenu_sel },

    -- Standard Syntax Highlighting
    Keyword = { fg = colors.keyword, bold = true },
    String = { fg = colors.string },
    Function = { fg = colors.Function },
    Constant = { fg = colors.constant },
    Type = { fg = colors.type },
    Number = { fg = colors.number },
    Boolean = { fg = colors.boolean },
    Operator = { fg = colors.operator },
    Identifier = { fg = colors.identifier },

    -- Dashboard (alpha-nvim)
    SnacksDashboardHeader = { fg = colors.keyword, bold = true },
    SnacksDashboardButton = { fg = colors.Function },
    SnacksDashboardButtonShortcut = { fg = colors.number },
    SnacksDashboardFooter = { fg = colors.comment },
    Special = { fg = colors.Function },
    Directory = { fg = colors.search },
    Question = { fg = colors.boolean },

    -- Treesitter
    ["@string"] = { fg = colors.string },
    ["@function"] = { fg = colors.func },
    ["@keyword"] = { fg = colors.keyword },
    ["@type"] = { fg = colors.type },
    ["@constant"] = { fg = colors.constant },

    -- Diagnostics
    DiagnosticError = { fg = colors.diag_error },
    DiagnosticWarn = { fg = colors.diag_warn },
    DiagnosticInfo = { fg = colors.diag_info },
    DiagnosticHint = { fg = colors.diag_hint },
  }
end

return M
