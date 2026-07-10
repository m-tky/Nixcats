require("lze").load({
	{
		"aerial.nvim",
		for_cat = aerial,
		after = function(_)
			require("aerial").setup({
				-- optionally use on_attach to set keymaps when aerial has attached to a buffer
				on_attach = function(bufnr)
					-- Jump forwards/backwards with '{' and '}'
					vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
					vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
				end,
				backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },
				layout = {
					min_width = 20,
					max_width = { 40, 0.2 },
				},
				filter_kind = false,
				autojump = true,
			})
			-- You probably also want to set a keymap to toggle aerial
			vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
		end,
		keys = { "<leader>a", "<cmd>AerialToggle!<cr>", desc = "Toggle Aerial" },
	},
	{
		"nvim-navic",
		event = "LspAttach",
		after = function()
			require("nvim-navic").setup({
				icons = {
					File = "󰈙 ",
					Module = " ",
					Namespace = "󰌗 ",
					Package = " ",
					Class = "󰌗 ",
					Method = "󰆧 ",
					Property = " ",
					Field = " ",
					Constructor = " ",
					Enum = "󰕘",
					Interface = "󰕘",
					Function = "󰊕 ",
					Variable = "󰆧 ",
					Constant = "󰏿 ",
					String = "󰀬 ",
					Number = "󰎠 ",
					Boolean = "◩ ",
					Array = "󰅪 ",
					Object = "󰅩 ",
					Key = "󰌋 ",
					Null = "󰟢 ",
					EnumMember = " ",
					Struct = "󰌗 ",
					Event = " ",
					Operator = "󰆕 ",
					TypeParameter = "󰊄 ",
				},
				lsp = {
					auto_attach = true,
					preference = nil,
				},
				highlight = true,
				separator = " > ",
				depth_limit = 0,
				depth_limit_indicator = "..",
				safe_output = true,
				lazy_update_context = false,
				click = true,
			})
		end,
	},
	{
		"nvim-lspconfig",
		event = "DeferredUIEnter",
		after = function(_)
			vim.diagnostic.config({
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.INFO] = " ",
						[vim.diagnostic.severity.HINT] = " ",
					},
				},
				underline = true,
				virtual_text = true,
				virtual_line = false,
				update_in_insert = false,
				severity_sort = true,
				float = {
					border = "single",
					title = "Diagnostics",
					header = {},
					suffix = {},
					format = function(diag)
						if diag.code then
							return string.format("[%s](%s): %s", diag.source, diag.code, diag.message)
						else
							return string.format("[%s]: %s", diag.source, diag.message)
						end
					end,
				},
			})
			local LspList = {
				"pyright",
				"ruff",
				"marksman",
				"ts_ls",
				"rust_analyzer",
				"lua_ls",
				"nil_ls",
				"bashls",
				"clangd",
				"sqls",
				"tinymist",
				"yamlls",
			}
			vim.lsp.config("*", {})
			vim.lsp.config(
				"lua_ls",
				{ cmd = { "lua-lsp" }, settings = { Lua = { diagnostics = { globals = { "vim" } } } } }
			)
			vim.lsp.config("pyright", {
				settings = {
					python = { analysis = { diagnosticSeverityOverrides = { reportUnusedExpression = "none" } } },
				},
			})
			vim.lsp.enable(LspList)
		end,
		dep_of = {
			"nvim-navic",
			"nvim-navbuddy",
			"trouble.nvim",
			"aerial.nvim",
			"quarto-nvim",
		},
	},
	{
		"trouble.nvim",
		after = function()
			require("trouble").setup({})
		end,
		keys = {
			{
				"<leader>xs",
				"<cmd>Trouble symbols toggle focus=false<CR>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>xl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<CR>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<CR>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<CR>",
				desc = "Quickfix List (Trouble)",
			},
			{
				"<leader>xx",
				function()
					require("trouble").toggle({
						mode = "diagnostics",
						filter = { buf = 0 },
						sort = { { "severity", "desc" } },
						preview = { type = "split", relative = "win", position = "right", size = 0.4 },
					})
				end,
				desc = "Trouble: Current Buffer Diagnostics",
			},
			{
				"<leader>xX",
				function()
					require("trouble").toggle({
						mode = "diagnostics",
						sort = { { "severity", "desc" } },
						preview = { type = "split", relative = "win", position = "right", size = 0.4 },
					})
				end,
				desc = "Trouble: All Buffers Diagnostics",
			},
		},
	},
})

local lsp_keymaps = {
	{ "gd", vim.lsp.buf.definition, "Go to definition" },
	{ "gD", vim.lsp.buf.references, "Find references" },
	{ "gt", vim.lsp.buf.type_definition, "Go to type definition" },
	{ "gi", vim.lsp.buf.implementation, "Go to implementation" },
	{ "K", vim.lsp.buf.hover, "Hover info" },
	{
		"<leader>lk",
		function()
			vim.diagnostic.jump({ count = -1, float = true })
		end,
		"Previous diagnostic",
	},
	{
		"<leader>lj",
		function()
			vim.diagnostic.jump({ count = 1, float = true })
		end,
		"Next diagnostic",
	},
	{ "<leader>lx", "<CMD>LspStop<CR>", "LSP stop" },
	{ "<leader>ls", "<CMD>LspStart<CR>", "LSP start" },
	{ "<leader>lr", "<CMD>LspRestart<CR>", "LSP restart" },
}

local lsp_keymap_group = vim.api.nvim_create_augroup("DefaultLspKeymaps", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
	group = lsp_keymap_group,
	desc = "Load LSP keymaps",
	callback = function(args)
		for _, map in ipairs(lsp_keymaps) do
			vim.keymap.set("", map[1], map[2], { buffer = args.buf, desc = map[3] })
		end
	end,
})
