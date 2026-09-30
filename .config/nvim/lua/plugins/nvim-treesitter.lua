return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.config")

    configs.setup({
      -- Automatically install parsers that are missing
      ensure_installed = { "rust", "javascript", "lua", "vim", "vimdoc" },

      -- Install parsers synchronously (only applied during ensure_installed)
      sync_install = false,

      -- Automatically install missing parsers when entering a buffer
      auto_install = true,

      highlight = {
        enable = true, -- Enable syntax highlighting
      },
    })
  end,
}
