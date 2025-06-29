return {
  {
    "stevearc/oil.nvim",
    opts = {
      keymaps = {
        ["<Esc><Esc>"] = { "actions.close", mode = "n" },
      },
      float = {
        max_width = 0.4,
        override = function(defaults)
          defaults["col"] = 1
          return defaults
        end,
      },
    },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
  },
  vim.keymap.set("n", "-", function()
    require("oil").open_float()
  end, { desc = "Open Oil in float" }),
}
