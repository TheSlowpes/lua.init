return {
  -- LSP Configuration and Servers
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim",    opts = {} },
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          }
        }
      }
    },
    config = function()
      -- General LSP settings and keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Keymaps for LSP actions
          map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
          map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
          map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementations")
          map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
          map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
          map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")
          map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Worspace Symbols")
          map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")


          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- Document Highlight
          if client and client.supports_method("textDocument/documentHighlight") then
            local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = true })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
          end

          -- Inlay Hints
          if client and client.supports_method("textDocument/inlayHint") then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "[T]oggle Inlay [H]ints")
          end
        end,
      })

      -- Diagnostic configuration
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
          },
        },
        virtual_text = {
          source = "if_many",
          spacing = 2,
        },
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Server configurations
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
              diagnostics = { globals = { "vim" } },
              runtime = { version = "LuaJIT" },
            },
          },
        },
        pyright = {},
        eslint = {
        },
        gopls = {},
        ts_ls = {},
      }

      -- Mason setup for ensuring servers are installed
      require("mason").setup()
      local mason_lspconfig = require("mason-lspconfig")

      -- This single block replaces the previous setup and setup_handlers calls
      mason_lspconfig.setup({
        -- A list of servers to install
        ensure_installed = vim.tbl_keys(servers),

        -- This is the key part: handlers are defined inside the setup call
        handlers = {
          -- This is the default handler that will apply to all servers
          -- without a specific handler below.
          function(server_name)
            local server_opts = servers[server_name] or {}
            server_opts.capabilities = capabilities
            require("lspconfig")[server_name].setup(server_opts)
          end,

          -- Here is a custom handler specifically for the eslint server
          ["eslint"] = function()
            require("lspconfig").eslint.setup({
              capabilities = capabilities,
              filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
            })
          end,
          ["gopls"] = function()
            require("lspconfig").gopls.setup({
              filetypes = { "go", "gomod", "gowork", "gotmpl" },
              settings = {
                gopls = {
                  completeUnimported = true,
                  usePlaceholders = true,
                  analyses = {
                    unusedparams = true
                  }
                }
              }
            })
          end,
        },
      })
    end,
  },

  -- Formatter Configuration
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "n",
        desc = "[F]ormat Buffer",
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        go = { "gofmt", "goimports" },
      },
    },
    config = function(_, opts)
      require("conform").setup(opts)

      -- Ensure formatters are installed
      local mason_tool_installer = require("mason-tool-installer")
      local formatters = {}
      for _, ft_formatters in pairs(opts.formatters_by_ft) do
        for _, formatter in ipairs(ft_formatters) do
          formatters[formatter] = true
        end
      end
      mason_tool_installer.setup({ ensure_installed = vim.tbl_keys(formatters) })
    end
  },
  -- Completion Engine
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = {
          -- Select the next and previous item
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),

          -- Scroll documentation
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),

          -- Abort completion
          ["<C-e>"] = cmp.mapping.abort(),

          -- Manually trigger completion
          ["<C-Space>"] = cmp.mapping.complete(),

          -- Accept ('Y'ank) selection
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        })
      })
    end
  },
  {
    "L3MON4D3/LuaSnip",
    version = "2.*",
    build = "make install_jsregexp",
  }
}
