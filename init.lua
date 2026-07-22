-- Cache compiled Lua chunks before loading the configuration.  This is a no-op on
-- Neovim versions that do not provide the built-in loader.
if vim.loader then
	vim.loader.enable()
end

-- Define leaders before plugin specs register their lazy key bindings.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Provide safe defaults when this file is inspected outside the Nix wrapper.
require("nixCatsUtils").setup({
	non_nix_value = true,
})

require("Default")
