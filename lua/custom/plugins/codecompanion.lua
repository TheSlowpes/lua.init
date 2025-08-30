return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 150,
          keymap = {
            accept = "<S-TAB>",
            accept_word = "<C-l>",
            accept_line = "<C-j>",
            dismiss = "<C-k>",
          },
        },
      })
    end,
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "ravitemer/codecompanion-history.nvim",
    },
    config = function()
      require("codecompanion").setup({
        display = {
          chat = {
            auto_scroll = false,
            show_references = true,
            start_in_insert_mode = true,
          },
          diff = {
            enabled = true,
            close_chat_at = 240,
            layout = "horizontal",
            provider = "mini_diff",
          },
        },
        adapters = {
          opts = { show_defaults = false, show_model_choices = true },
          copilot = function()
            return require("codecompanion.adapters.http").extend("copilot", {
              schema = {
                model = {
                  default = "claude-3.7-sonnet",
                },
              },
            })
          end,
          gemini = function()
            return require("codecompanion.adapters.http").extend("gemini", {
              env = { api_key = os.getenv("GEMINI_API_KEY") },
              schema = {
                model = {
                  default = "gemini-2.5-flash-preview-05-20",
                },
              },
            })
          end,
        },
        strategies = {
          inline = {
            layout = "vertical",
            keymaps = {
              accept_change = {
                modes = { n = "<S-TAB>" },
                index = 1,
                callback = "keymap.accept_change",
                description = "Accept Change",
              },
              reject_change = {
                modes = { n = "<C-k>" },
                index = 2,
                callback = "keymap.reject_change",
                description = "Reject Change",
              },
            },
          },
          chat = {
            roles = {
              ---The header name for the LLM's messages
              ---@type string|fun(adapter: CodeCompanion.HTTPAdapter): string
              llm = function(adapter)
                local model_name = ""
                local adapter_icon = ""
                if adapter.schema and adapter.schema.model and adapter.schema.model.default then
                  local model = adapter.schema.model.default
                  if type(model) == "function" then
                    model = model(adapter)
                  end
                  model_name = "(" .. model .. ")"
                end
                if adapter.schema and adapter.schema.model then
                  local adapter_name = adapter.formatted_name
                  if adapter_name == "Copilot" then
                    adapter_icon = " "
                  elseif adapter_name == "Gemini" then
                    adapter_icon = " "
                  end
                end
                vim.g.codecompanion_adapter = adapter_icon .. adapter.formatted_name
                return adapter_icon .. adapter.formatted_name .. model_name
              end,
              ---The header name for your messages
              ---@type string
              user = "kslowpes",
            },
          },
        },
        extensions = {
          history = {
            enabled = true,
            opts = {
              keymap = "<leader>ch",
              auto_save = true,
              expiration_days = 0,
              picker = "telescope",
              picker_keymaps = {
                rename = { n = "ce", i = "<M-r>" },
                delete = { n = "dd", i = "<M-d>" },
                duplicate = { n = "<M-J>", i = "<M-J>" },
              },
              auto_generate_title = true,
              title_generation_opts = {
                refresh_every_n_prompts = 3,
                max_refreshes = 3,
              },
              continue_last_chat = true,
              delete_on_clearing_chat = false,
              dir_to_save = vim.fn.stdpath("data") .. "/codecompanion/history",
              enable_logging = true,
            },
          },
        },
      }
      )
      vim.keymap.set("n", "<leader>a", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Code Companion: Chat" })
      vim.keymap.set(
        "n",
        "<leader>cc",
        "<cmd>CodeCompanionChat copilot<cr>",
        { desc = "[C]ode Companion: [C]opilot" }
      )
      vim.keymap.set(
        "n",
        "<leader>cg",
        "<cmd>CodeCompanionChat gemini<cr>",
        { desc = "[C]ode Companion: [G]emini" }
      )
      -- vim.keymap.set("v", "<leader>ci", "<cmd>CodeCompanion<cr>", { desc = "[C]ode Companion: [I]nline Chat" })
      -- vim.keymap.set("n", "<leader>ci", "<cmd>CodeCompanion<cr>", { desc = "[C]ode Companion: [I]nline Chat" })
    end,
  },
}
