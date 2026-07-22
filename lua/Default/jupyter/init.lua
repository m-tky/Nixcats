require("lze").load({
	{
		"jovian-nvim",
		after = function()
			require("jovian").setup({
				cell_frame = true, -- bordered cell cards
				markdown_cell_style = true, -- styled markdown cells
				inline_outputs = true, -- output rendered below cells
				cell_frame_right_pad = 1,
				ui_symbols = {
					running = " ",
					done = " ",
					error = " ",
					interrupted = " ",
					stale = " ",
				},
			})
		end,
		keys = {
			{ "<leader>jt", "<cmd>JovianToggle<cr>", desc = "Open Jovian UI" },
			{ "<leader>jo", "<cmd>JovianToggleOutput<cr>", desc = "Toggle output window" },
			{ "<leader>jc", "<cmd>JovianClearREPL<cr>", desc = "Clear REPL" },
			{ "<leader>jr", "<cmd>JovianRun<cr>", desc = "Run current cell" },
			{ "<leader>jn", "<cmd>JovianRunAndNext<cr>", desc = "Run cell and next" },
			{ "<leader>ja", "<cmd>JovianRunAll<cr>", desc = "Run all cells" },
			{ "<leader>jl", "<cmd>JovianRunLine<cr>", desc = "Run current line" },
			{ "<leader>jv", "<cmd>JovianSendSelection<cr>", mode = "v", desc = "Run visual selection" },
			{ "<leader>js", "<cmd>JovianStart<cr>", desc = "Start kernel" },
			{ "<leader>jR", "<cmd>JovianRestart<cr>", desc = "Restart kernel" },
			{ "<leader>ji", "<cmd>JovianInterrupt<cr>", desc = "Interrupt execution" },
			{ "<leader>jC", "<cmd>JovianClean<cr>", desc = "Clean cache" },
			{ "<leader>jj", "<cmd>JovianNextCell<cr>", desc = "Next cell" },
			{ "<leader>jk", "<cmd>JovianPrevCell<cr>", desc = "Previous cell" },
			{ "<leader>jA", "<cmd>JovianNewCellAbove<cr>", desc = "New cell above" },
			{ "<leader>jB", "<cmd>JovianNewCellBelow<cr>", desc = "New cell below" },
			{ "<leader>jd", "<cmd>JovianDeleteCell<cr>", desc = "Delete cell" },
			{ "<leader>jK", "<cmd>JovianMoveCellUp<cr>", desc = "Move cell up" },
			{ "<leader>jJ", "<cmd>JovianMoveCellDown<cr>", desc = "Move cell down" },
			{ "<leader>jm", "<cmd>JovianMergeBelow<cr>", desc = "Merge with below" },
			{ "<leader>jx", "<cmd>JovianSplitCell<cr>", desc = "Split cell at cursor" },
			{ "<leader>jV", "<cmd>JovianVars<cr>", desc = "Show variables" },
			{ "<leader>jD", "<cmd>JovianInspect<cr>", desc = "Inspect symbol" },
			{ "<leader>jw", "<cmd>JovianView<cr>", desc = "View variable" },
		},
	},
	{
		"hydra.nvim",
		dep_of = "jovian-nvim",
		after = function()
			local hydra = require("hydra")
			hydra({
				name = "Jupyter",
				hint = [[
  _J_/_K_: move down/up  _R_: run cell _L_: send line
_S_: run visual  _C_: new code cell _M_: new markdown cell
]],
				config = {
					color = "pink",
					invoke_on_body = true,
					hint = {
						float_opts = {
							border = "rounded", -- you can change the border if you want
						},
					},
				},
				mode = { "n" },
				body = "<localleader>J", -- Jupyter command mode
				heads = {
					{ "J", ":JovianNextCell<CR>" },
					{ "K", ":JovianPrevCell<CR>" },
					{ "R", ":JovianRun<CR>" },
					{ "L", ":JovianRunLine<CR>" },
					{ "S", ":JovianSendSelection<CR>" },
					{ "C", ":JovianNewCellBelow<CR>" },
					{ "M", ":JovianNewMarkdownCellBelow<CR>" },
					{ "<esc>", nil, { exit = true } },
					{ "q", nil, { exit = true } },
				},
			})
		end,
	},
})
