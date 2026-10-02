return {
	{
		"mason-org/mason.nvim",
		lazy = false,
		opts = {},
		config = function()
			require("mason").setup()
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		lazy = false,
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"bashls",
					"clangd", -- C/C++
					--"cmake",
					"cssls",
					"dockerls",
					"gopls",
					"html",
					"jsonls",
					"lua_ls",
					"qmlls",
					"rust_analyzer",
					"sqlls",
					"ts_ls",
					"vimls",
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			vim.lsp.config("*", { capabilities = capabilities })
			vim.lsp.enable({
				"bashls",
				"clangd",
				--"cmake",
				"cssls",
				"dockerls",
				"gopls",
				"html",
				"jsonls",
				"lua_ls",
				"qmlls",
				"rust_analyzer",
				"sqlls",
				"ts_ls",
				"vimls",
			})

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
		end,
	},
}
