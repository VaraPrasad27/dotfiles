return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        -- Shell (Bash & Zsh)
        null_ls.builtins.formatting.shfmt,
        -- null_ls.builtins.diagnostics.shellcheck,

        -- C / C++ / CMake
        null_ls.builtins.formatting.clang_format,
        -- null_ls.builtins.formatting.cmake_format,
        -- null_ls.builtins.diagnostics.cmake_lint,

        -- Web Dev (HTML, CSS, JS, TS, JSON)
        null_ls.builtins.formatting.prettier,

        -- Go
        null_ls.builtins.formatting.gofmt,
        null_ls.builtins.formatting.goimports,
        null_ls.builtins.diagnostics.golangci_lint,

        -- Dockerfile
        null_ls.builtins.diagnostics.hadolint,

        -- Lua & Vim
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.diagnostics.selene,
        null_ls.builtins.diagnostics.vint,

        -- Rust
        -- null_ls.builtins.formatting.rust_analyzer,

        -- SQL
        null_ls.builtins.formatting.sqlfluff,
        null_ls.builtins.diagnostics.sqlfluff,

        -- QML
        null_ls.builtins.formatting.qmlformat,
        null_ls.builtins.diagnostics.qmllint,
      },
    })

    vim.keymap.set("n", "<leader>gf", function()
      require("config.format").format()
    end, { desc = "Format buffer" })
  end,
}
