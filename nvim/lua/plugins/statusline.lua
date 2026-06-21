return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local colors = {
        base = "#1e1e2e",
        surface0 = "#313244",
        surface1 = "#45475a",
        text = "#cdd6f4",
        blue = "#89b4fa",
        green = "#a6e3a1",
        mauve = "#cba6f7",
        peach = "#fab387",
        red = "#f38ba8",
      }

      local theme = {
        normal = {
          a = { fg = colors.base, bg = colors.blue, gui = "bold" },
          b = { fg = colors.text, bg = colors.surface1 },
          c = { fg = colors.text, bg = colors.surface0 },
        },
        insert = { a = { fg = colors.base, bg = colors.green, gui = "bold" } },
        visual = { a = { fg = colors.base, bg = colors.mauve, gui = "bold" } },
        replace = { a = { fg = colors.base, bg = colors.red, gui = "bold" } },
        command = { a = { fg = colors.base, bg = colors.peach, gui = "bold" } },
        inactive = {
          a = { fg = colors.text, bg = colors.surface0 },
          b = { fg = colors.text, bg = colors.surface0 },
          c = { fg = colors.text, bg = colors.base },
        },
      }

      require("lualine").setup({
        options = {
          theme = theme,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff" },
          lualine_c = {
            {
              "filename",
              path = 1,
              symbols = { modified = " [+]", readonly = " [RO]", unnamed = "[No Name]" },
            },
          },
          lualine_x = { "diagnostics", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },
}
