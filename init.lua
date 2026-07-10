-- Provide safe defaults when this file is inspected outside the Nix wrapper.
require("nixCatsUtils").setup({
  non_nix_value = true,
})

require("Default")
