return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        local colors_path = vim.fn.expand("~/.local/state/theme/generated/nvim-colors.lua")
        local f = io.open(colors_path, "r")
        if f then
          f:close()
          local ok, c = pcall(dofile, colors_path)
          if ok and type(c) == "table" then
            vim.cmd("highlight clear")
            if vim.fn.exists("syntax_on") then
              vim.cmd("syntax reset")
            end
            vim.o.termguicolors = true
            vim.g.colors_name = "matugen"

            local hl = vim.api.nvim_set_hl

            -- Editor base
            hl(0, "Normal", { fg = c.on_surface, bg = "NONE" })
            hl(0, "NormalFloat", { fg = c.on_surface, bg = c.surface_container })
            hl(0, "FloatBorder", { fg = c.primary, bg = "NONE" })
            hl(0, "CursorLine", { bg = c.surface_container })
            hl(0, "CursorLineNr", { fg = c.primary, bold = true })
            hl(0, "LineNr", { fg = c.outline })
            hl(0, "Visual", { bg = c.primary_container, fg = c.on_primary_container })
            hl(0, "Search", { bg = c.primary, fg = c.on_primary })
            hl(0, "IncSearch", { bg = c.tertiary, fg = c.on_primary })
            hl(0, "Directory", { fg = c.primary })
            hl(0, "Title", { fg = c.primary, bold = true })

            -- Syntax
            hl(0, "Comment", { fg = c.outline, italic = true })
            hl(0, "Constant", { fg = c.secondary })
            hl(0, "String", { fg = "#9ece6a" })
            hl(0, "Number", { fg = "#ff9e64" })
            hl(0, "Identifier", { fg = c.on_surface })
            hl(0, "Function", { fg = c.primary, bold = true })
            hl(0, "Statement", { fg = c.tertiary, bold = true })
            hl(0, "Keyword", { fg = c.tertiary, bold = true })
            hl(0, "Type", { fg = c.secondary })
            hl(0, "Special", { fg = c.tertiary })

            -- Diagnostics
            hl(0, "DiagnosticError", { fg = c.error })
            hl(0, "DiagnosticWarn", { fg = "#e0af68" })
            hl(0, "DiagnosticInfo", { fg = c.primary })
            hl(0, "DiagnosticHint", { fg = c.secondary })

            -- Plugins (Telescope, NeoTree, WhichKey)
            hl(0, "TelescopeBorder", { fg = c.primary })
            hl(0, "TelescopePromptBorder", { fg = c.primary })
            hl(0, "TelescopeSelection", { bg = c.surface_container_high, fg = c.on_surface })
            hl(0, "NeoTreeNormal", { fg = c.on_surface, bg = "NONE" })
            hl(0, "NeoTreeNormalNC", { fg = c.on_surface, bg = "NONE" })
            hl(0, "NeoTreeDirectoryName", { fg = c.primary })
            hl(0, "NeoTreeDirectoryIcon", { fg = c.primary })
            hl(0, "WhichKeyBorder", { fg = c.primary })
            return
          end
        end
        vim.cmd("colorscheme tokyonight")
      end,
    },
  },
}
