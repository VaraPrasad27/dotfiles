return {
  "nvim-mini/mini.nvim",
  version = "*",
  dependencies = { "JoosepAlviste/nvim-ts-context-commentstring", opts = { enable_autocmd = false } },
  config = function()
    require("mini.comment").setup({
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring()
              or vim.bo.commentstring
        end,
      },
    })
    require("mini.surround").setup({})
    require("mini.indentscope").setup({})
    require("mini.pairs").setup({})
    require("mini.icons").setup({})
  end,
}
