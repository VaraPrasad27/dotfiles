return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local configs = require("nvim-treesitter.config")

		configs.setup({
			ensure_installed = {
				"bash",
				"c",
				"cmake",
				"cpp",
				"css",
				"dockerfile",
				"go",
				"html",
				"javascript",
				"json",
				"lua",
				"rust",
				"sql",
				"typescript",
				"vim",
				"vimdoc",
				"zsh",
			},
			sync_install = false,
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
