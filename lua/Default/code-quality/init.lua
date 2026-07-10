require("lze").load({
	{
		"nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		after = function(_)
			local lint = require("lint")
			lint.linters_by_ft = {
				sh = { "shellcheck" },
				bash = { "shellcheck" },
				zsh = { "shellcheck" },
				python = { "ruff" },
				lua = { "luacheck" },
				rust = { "clippy" },
				nix = { "statix", "deadnix" },
				markdown = { "markdownlint-cli2" },
				cpp = { "clangtidy" },
				sql = { "sqlfluff" },
				yaml = { "yq" },
				docker = { "hadolint" },
			}

			local lint_group = vim.api.nvim_create_augroup("DefaultLint", { clear = true })
			vim.api.nvim_create_autocmd("BufWritePost", {
				group = lint_group,
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
	{
		"conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				-- Customize or remove this keymap to your liking
				"<leader>lf",
				function()
					require("conform").format({ async = true })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		after = function(_)
			require("conform").setup({
				formatters_by_ft = {
					rust = { "rustfmt" },
					python = { "isort", "black" },
					markdown = { "prettier" },
					lua = { "stylua" },
					nix = { "nixfmt" },
					cpp = { "clang-format" },
					sh = { "shfmt" },
					bash = { "shfmt" },
					zsh = { "shfmt" },
					sql = { "sqlfluff" },
					typst = { "typstyle" },
					yaml = { "yq" },
					json = { "yq" },
					xml = { "yq" },
				},
				format_on_save = {
					-- These options will be passed to conform.format()
					timeout_ms = 500,
					lsp_format = "never",
				},
			})
			local format_group = vim.api.nvim_create_augroup("DefaultFormat", { clear = true })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = format_group,
				pattern = "*",
				callback = function(args)
					require("conform").format({ bufnr = args.buf })
				end,
			})
		end,
	},
})
