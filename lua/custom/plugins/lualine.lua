return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local codecompanion = require("custom.plugins.lualine.codecompanion_component")
      local tmux_status = require("tmux-status")
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "horizon",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = { "dashboard", "lazy", "mason", "alpha" },
            winbar = { "dashboard", "lazy", "mason", "alpha" },
          },
          ignore_focus = {},
          always_divide_middle = true,
          global_status = true,
          refresh = {
            statusline = 1000,
            winbar = 1000,
            refresh_time = 16,
            events = {
              "WinEnter",
              "BufEnter",
              "BufWritePost",
              "SessionLoadPost",
              "FileChangedShellPost",
              "VimResized",
              "Filetype",
              "CursorMoved",
              "CursorMovedI",
              "ModeChanged",
            },
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename", "filesize" },
          lualine_x = { "encoding", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        winbar = {
          lualine_x = { "lsp_status" },
          lualine_z = {
            codecompanion,
          },
        },
      })
    end,
  },
}
