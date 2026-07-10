require("lze").load({
	{
		"nvim-nio",
		dep_of = { "nvim-dap-ui" },
		-- dep_of = { "nvim-dap" },
	},
	{
		"nvim-dap",
		-- dep_of = { "nvim-dap-ui", "nvim-nio", "lazydev.nvim", "nvim-dap-virtual-text" },
		dep_of = { "nvim-dap-ui" },
		lazy = true,
		after = function(_)
			local dap = require("dap")

			-- lldb-dap can debug C, C++, and Rust.  The key used here must
			-- match the `type` field in every configuration below.
			dap.adapters.lldb = {
				type = "executable",
				command = "lldb-dap", -- or if not in $PATH: "/absolute/path/to/codelldb"
				name = "lldb",
			}

			local function build_if_needed(exe, build_cmd)
				if vim.fn.filereadable(exe) == 1 then
					local choice = vim.fn.input(exe .. " exists. Rebuild? (y/N): ")
					if not (choice == "y" or choice == "Y") then
						return true
					end
				end
				local ok = os.execute(build_cmd) == 0
				if not ok then
					vim.notify("Build failed: " .. build_cmd, vim.log.levels.ERROR)
				end
				return ok
			end

			local function lldb_launch_config(name, program)
				return {
					name = name,
					type = "lldb",
					request = "launch",
					program = program,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				}
			end

			local function compile_c_family(compiler, source)
				return function()
					local cwd = vim.fn.getcwd()
					local exe = cwd .. "/a.out"
					local src = cwd .. "/" .. source
					local cmd = string.format(
						"%s -g -O0 -fno-omit-frame-pointer -o %s %s",
						compiler,
						vim.fn.shellescape(exe),
						vim.fn.shellescape(src)
					)
					return build_if_needed(exe, cmd) and exe or nil
				end
			end

			dap.configurations.c = {
				lldb_launch_config("Build(if needed) & Launch (C)", compile_c_family("clang", "main.c")),
			}
			dap.configurations.cpp = {
				lldb_launch_config("Build(if needed) & Launch (C++)", compile_c_family("clang++", "main.cpp")),
			}

			local function cargo_binary_target(cargo)
				local root_id = cargo.resolve and cargo.resolve.root
				for _, package in ipairs(cargo.packages or {}) do
					if package.id == root_id then
						for _, target in ipairs(package.targets) do
							if vim.tbl_contains(target.kind, "bin") then
								return target
							end
						end
					end
				end
			end

			dap.configurations.rust = {
				lldb_launch_config("Build(if needed) & Launch (Rust - Cargo)", function()
					local metadata = vim.fn.system({ "cargo", "metadata", "--no-deps", "--format-version", "1" })
					if vim.v.shell_error ~= 0 then
						vim.notify("Cargo.toml was not found", vim.log.levels.ERROR)
						return nil
					end

					local ok, cargo = pcall(vim.json.decode, metadata)
					local target = ok and cargo_binary_target(cargo)
					if not target then
						vim.notify("No debuggable binary target was found", vim.log.levels.ERROR)
						return nil
					end

					local exe = cargo.target_directory .. "/debug/" .. target.name
					local cmd = "cargo build"
					return build_if_needed(exe, cmd) and exe or nil
				end),
			}

			-- python
			dap.adapters.python = function(cb, config)
				if config.request == "attach" then
					---@diagnostic disable-next-line: undefined-field
					local port = (config.connect or config).port
					---@diagnostic disable-next-line: undefined-field
					local host = (config.connect or config).host or "127.0.0.1"
					cb({
						type = "server",
						port = assert(port, "`connect.port` is required for a python `attach` configuration"),
						host = host,
						options = {
							source_filetype = "python",
						},
					})
				else
					cb({
						type = "executable",
						command = "debugpy",
						-- args = { "-m", "debugpy.adapter" },
						options = {
							source_filetype = "python",
						},
					})
				end
			end

			dap.configurations.python = {
				{
					-- The first three options are required by nvim-dap
					type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
					request = "launch",
					name = "Launch file",

					-- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

					program = "${file}", -- This configuration will launch the current file if used.
					pythonPath = function()
						-- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
						-- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
						-- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
						local cwd = vim.fn.getcwd()
						if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
							return cwd .. "/venv/bin/python"
						elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
							return cwd .. "/.venv/bin/python"
						else
							return "python3"
						end
					end,
				},
			}
		end,
		keys = {
			{
				"<leader>dt",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle Breakpoint",
			},
			{
				"<leader>dc",
				function()
					require("dap").continue()
				end,
				desc = "Continue",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Step Into",
			},
			{
				"<leader>do",
				function()
					require("dap").step_over()
				end,
				desc = "Step Over",
			},
			{
				"<leader>du",
				function()
					require("dap").step_out()
				end,
				desc = "Step Out",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.open()
				end,
				desc = "Open REPL",
			},
			{
				"<leader>dl",
				function()
					require("dap").run_last()
				end,
				desc = "Run Last",
			},
			{
				"<leader>dq",
				function()
					require("dap").terminate()
					require("dapui").close()
				end,
				desc = "Terminate",
			},
			{
				"<leader>db",
				function()
					require("dap").list_breakpoints()
				end,
				desc = "List Breakpoints",
			},
			{
				"<leader>de",
				function()
					require("dap").set_exception_breakpoints({ "all" })
				end,
				desc = "Set Exception Breakpoints",
			},
		},
	},
	{
		"nvim-dap-ui",
		-- dep_of = { "nvim-dap" },
		lazy = true,
		after = function(_)
			require("dapui").setup({})

			local dap, dapui = require("dap"), require("dapui")
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
		end,
		keys = {
			{
				"<leader>dv",
				function()
					require("dapui").toggle({})
				end,
				desc = "Dap UI",
			},
		},
	},
	{
		"lazydev.nvim",
		ft = "lua",
		dep_of = { "nvim-dap-ui" },
		-- dep_of = { "nvim-dap" },
		lazy = true,
		after = function(_)
			require("lazydev").setup({
				library = { "nvim-dap-ui" },
			})
		end,
	},
	{
		"nvim-dap-virtual-text",
		dep_of = { "nvim-dap-ui" },
		lazy = true,
		after = function(_)
			require("nvim-dap-virtual-text").setup({})
		end,
	},
})
