return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "Format file" },
    },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "biome", "prettierd", "prettier", stop_after_first = true },
          javascriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
          typescript = { "biome", "prettierd", "prettier", stop_after_first = true },
          typescriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
          json = { "biome", "prettierd", "prettier", stop_after_first = true },
          css = { "biome", "prettierd", "prettier", stop_after_first = true },
          scss = { "prettierd", "prettier", stop_after_first = true },
          html = { "prettierd", "prettier", stop_after_first = true },
          markdown = { "prettierd", "prettier", stop_after_first = true },
          lua = { "stylua" },
        },
        format_on_save = function(bufnr)
          if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then
            return
          end
          return { timeout_ms = 1200, lsp_fallback = true }
        end,
      })

      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, { bang = true, desc = "Disable format on save globally or for current buffer with !" })

      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = "Enable format on save" })
    end,
  },
}
