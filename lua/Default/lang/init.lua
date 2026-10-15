require("lze").load({
	{
		"img-clip.nvim",
		for_cat = "lang.markdown",
		cmd = { "PasteImage" },
		keys = {
			{ "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
		},
		after = function()
			require("img-clip").setup({
				default = {
					dir_path = "assets",
					relative_to_current_file = true,
				},
			})
		end,
	},
	{
		"obsidian.nvim",
		for_cat = "lang.markdown",
		ft = { "markdown" },
		cmd = { "Obsidian" },
		after = function()
			require("lze").trigger_load("snacks.nvim")
			require("obsidian").setup({
				legacy_commands = false,
				workspaces = {
					{ name = "personal", path = vim.fn.expand("~/Documents/Obsidian") },
				},
				picker = { name = "snacks.picker" },
				-- Keep Markdown rendering in render-markdown.nvim.
				ui = { enable = false },
			})
		end,
	},
	{
		"typst-preview.nvim",
		after = function()
			require("typst-preview").setup({
				-- dependencies_bin = { tinymist = "tinymist", websocat = "websocat" },
				dependencies_bin = {
					tinymist = vim.fn.exepath("tinymist"),
					websocat = vim.fn.exepath("websocat"),
				},
				invert_colors = "auto",
			})
		end,
		ft = { "typst" },
	},
	{
		"marp-nvim",
		after = function()
			require("marp-nvim").setup({})
		end,
		keys = {
			{ "<leader>MT", "<cmd>MarpToggle<cr>", mode = "", desc = "Toggle Marp", silent = true },
			{ "<leader>MS", "<cmd>MarpStatus<cr>", mode = "", desc = "Marp Status", silent = true },
		},
	},
	{
		"render-markdown.nvim",
		after = function()
			require("render-markdown").setup({
				code = { right_pad = 4, width = "block" },
				completions = { blink = { enabled = true } },
				file_types = { "markdown", "vimwiki" },
				heading = {
					enabled = false,
					left_pad = 0,
					render_modes = false,
					right_pad = 4,
					sign = true,
					width = "block",
				},
				injections = {
					gitcommit = {
						enabled = true,
						query = [[
              ((message) @injection.content
                (#set! injection.combined)
                (#set! injection.include-children)
                (#set! injection.language "markdown"))
            ]],
					},
				},
			})
			vim.api.nvim_create_user_command("RenderMarkdownOverlay", function()
				overlay.render_markdown_cells()
			end, {})
		end,
		ft = { "markdown" },
	},
})
