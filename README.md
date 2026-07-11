# Neovim Config — _david

Config Neovim cá nhân dựa trên [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), chạy được ở **hai môi trường**:

- **Terminal Neovim** — full plugin stack (LSP, Telescope, Treesitter, blink.cmp, flash.nvim...)
- **VSCode + vscode-neovim** — mini.ai + mini.surround + mini.move + flash.nvim + keymaps qua `vscode.action()`

## Yêu cầu

- Neovim stable mới nhất
- `git`, `make`, `ripgrep`, `fd`
- [Nerd Font](https://www.nerdfonts.com/) (đặt `vim.g.have_nerd_font = true` trong `init.lua`)
- Node.js (cho một số LSP server)
- Go toolchain (cho `gopls`, nếu code Go)

## Cài đặt

```bash
git clone https://github.com/datvt243/kickstart.nvim.git ~/.config/nvim
nvim
```

`vim.pack` sẽ tự cài toàn bộ plugin khi khởi động lần đầu.

## Plugin manager

Dùng **`vim.pack`** — plugin manager tích hợp sẵn trong Neovim (không dùng lazy.nvim):

```bash
:PackUpdate          # cập nhật plugin
:lua vim.pack.update(nil, { offline = true })   # xem trạng thái
:ReloadConfig         # reload toàn bộ config, không cần thoát/vào lại
```

## Cấu trúc

```
init.lua                        — options, keymaps chung, vim.pack hooks
keymaps-terminal.md              — danh sách keymaps cho Terminal Neovim (BOTH / TER)
keymaps-vscode.md                — danh sách keymaps cho VSCode (BOTH / VSC)
lua/
  custom/plugins/
    claudecode.lua              — Claude Code integration (terminal)
    noice.lua                   — noice.nvim floating UI (terminal)
    project.lua                 — project.nvim auto root + Telescope (terminal)
    terminal.lua                — toggleterm.nvim bottom terminal (terminal)
    codesnap.lua                — codesnap.nvim: chụp code thành ảnh (terminal)
    import-cost.lua             — vim-import-cost: KB từng import JS/TS (terminal)
    completion.lua              — blink.cmp + LuaSnip
    dashboard.lua               — dashboard-nvim
    format.lua                  — conform.nvim
    lsp.lua                     — nvim-lspconfig + Mason + fidget
    telescope.lua               — Telescope fuzzy finder
    treesitter.lua              — nvim-treesitter
    ui.lua                      — mini.nvim (ai, surround, move), flash.nvim, tokyonight, gitsigns...
    whichkey.lua                — which-key.nvim: gợi ý keymap khi gõ leader (terminal)
    vscode.lua                  — VSCode keymaps (VSCode only)
  kickstart/plugins/            — optional plugins (bật ở Section 10 của init.lua)
vscode/
  settings.json                 — VSCode settings (cross-platform: Mac + Windows)
  keybindings.json              — VSCode keybindings (copy vào User/keybindings.json)
```

## Keymaps nổi bật

> Xem đầy đủ tại [`keymaps-terminal.md`](keymaps-terminal.md) (Terminal Neovim) hoặc [`keymaps-vscode.md`](keymaps-vscode.md) (VSCode)

## VSCode — Extensions cần cài

| Extension | ID |
|---|---|
| vscode-neovim | `asvetliakov.vscode-neovim` |
| Which Key | `vspacecode.whichkey` |
| Find It Faster | `TomiTurtinen.find-it-faster` |
| Fuzzy Search | `jacobdufault.fuzzy-search` |
| Bookmarks | `alefragnani.Bookmarks` |
| Harpoon | `tobias-z.vscode-harpoon` |
| Project Manager | `alefragnani.project-manager` |

> Disable `vscodevim.vim` nếu đã cài: `code --disable-extension vscodevim.vim`

> **Jump:** Dùng `flash.nvim` (Neovim plugin) thay Jumpy — `<leader>j`. Jumpy bị bỏ vì conflict với vscode-neovim do hook `type` command.

## Thêm LSP server

Mở `lua/custom/plugins/lsp.lua`, thêm vào `local servers = { ... }`:

```lua
pyright = {},
```

Mason sẽ tự cài khi khởi động lại.

## Format Lua

```bash
~/.local/share/nvim/mason/bin/stylua init.lua lua/**/*.lua
```
