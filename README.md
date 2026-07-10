# My `nixCats` Neovim Configuration

This repository is a personal Neovim configuration managed entirely by [`nixCats`](https://nixcats.org/). Nix provides plugins, language servers, formatters, linters, and debuggers; [`lze`](https://github.com/BirdeeHub/lze) loads optional plugins on demand.

Run it directly with `nix run .#nixCats` (or `nix run .#`). This repository does not maintain a `paq`/`mason` fallback, so use the Nix-built package rather than loading the configuration directly with an unrelated Neovim installation.

## Directory Structure

The main files are:

- `flake.nix`: Nix inputs, plugins, and language tooling.
- `lua/Default/`: feature-oriented Neovim modules.
- `lua/nixCatsUtils/`: helpers used by the nixCats integration.
- `queries/`: custom Tree-sitter queries.

## Rust

Rust の開発環境は `flake.nix` の `rust` カテゴリで管理しています。Nix で起動した Neovim では、次のコマンドが PATH に追加されます。

- `cargo`, `rustc`, `rustfmt`, `cargo-clippy`
- `rust-analyzer`（LSP）
- `lldb-dap`（nvim-dap によるデバッグ）

`.rs` ファイルでは rust-analyzer による補完・診断、保存時の `rustfmt` 整形、保存後の Clippy lint が有効です。`<leader>dc` で DAP を開始すると、Cargo metadata から通常の binary target を特定し、`cargo build` 後に LLDB で起動します。ライブラリ専用 crate や複数 binary の workspace は、必要に応じて `lua/Default/debug/init.lua` に個別の DAP 設定を追加してください。
