# Repository Guidelines

## Project Structure & Module Organization

This is a NixCats-managed Neovim configuration. `flake.nix` declares Nix inputs, plugin categories, language tooling, and package outputs. The entry point is `init.lua`; feature modules live in `lua/Default/` (for example, `lsp/`, `debug/`, `code-quality/`, and `ui/`). Shared NixCats helpers are in `lua/nixCatsUtils/`. Put custom Tree-sitter queries under `queries/<language>/`.

Keep a feature's plugin declaration and its Lua setup aligned: add runtime tools in the relevant `flake.nix` category and configure the plugin in the matching `lua/Default/<feature>/init.lua` module.

## Build, Test, and Development Commands

- `nix run .#nixCats` (or `nix run .#`): launch the packaged Neovim configuration.
- `nix build .#nixCats --no-link`: build and validate the main package without creating a `result` symlink.
- `nix flake show --no-write-lock-file`: evaluate exported flake outputs.
- `nvim --headless -u NONE "+lua assert(loadfile('lua/Default/lsp/init.lua'))" +qa`: quickly check a Lua file for syntax errors.

Use the Nix-built package for validation so that language servers and plugins are available on `PATH`.

## Coding Style & Naming Conventions

Use tabs for Lua indentation and format changed Lua files with `stylua` (available through the packaged Neovim environment). Prefer small, feature-focused modules over growing `init.lua`. Use snake_case for Lua locals and descriptive augroup names such as `DefaultLint`.

Keep user-facing notification text in English. When adding a language server, verify its executable name against the Nix package and add it to both the runtime dependencies and the LSP configuration when appropriate.

## Testing Guidelines

There is no automated test suite. For every configuration change, run `nix build .#nixCats --no-link`, validate edited Lua files with `loadfile`, and run `git diff --check`. For keybindings or LSP changes, start the packaged Neovim headlessly or interactively to confirm the relevant command loads without errors.

## Commit & Pull Request Guidelines

History uses short, imperative feature commits such as `feat: flake update` and `feat: jovian update`. Follow the same `type: concise summary` pattern. Keep commits scoped by feature. Pull requests should explain the behavior change, list validation commands, mention Nix input or dependency updates, and include screenshots only for visible UI changes.

## Configuration Safety

Do not hand-edit `flake.lock` unless intentionally updating inputs. Avoid adding unpinned download managers or Mason-managed tooling; NixCats and `flake.nix` are the source of truth.
