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
  custom/plugins/                — tự động load đệ quy (kể cả subfolder), xem custom/plugins/init.lua
    dashboard.lua                — dashboard-nvim (terminal)
    lsp.lua                      — nvim-lspconfig + Mason + fidget + lazydev (terminal)
    telescope.lua                — Telescope fuzzy finder (terminal)
    vscode.lua                   — VSCode keymaps (VSCode only)
    editor/                      — plugin liên quan hành vi soạn thảo/motion (flash.nvim, mini.surround/move,
                                    neoscroll, scrollbar, indent guides, which-key, trouble.nvim, todo-comments)
    coding/                      — plugin hỗ trợ viết code (mini.ai, ts-comments, nvim-autopairs,
                                    blink.cmp, LuaSnip, lazydev)
    colorscheme/                 — tokyonight (active) + catppuccin (cài sẵn, tắt — đổi flag `active` để switch)
    formatting/                  — conform.nvim
    ui/                          — mini.icons, lualine, noice, bufferline (tắt mặc định)
    treesitter/                  — nvim-treesitter + nvim-ts-autotag
    tools/                       — tích hợp công cụ ngoài: claudecode, project.nvim, toggleterm,
                                    codesnap, vim-import-cost
  kickstart/plugins/             — optional plugin, bật/tắt bằng cách (un)comment ở Section 10 init.lua
    gitsigns.lua, neo-tree.lua   — đang bật
    debug.lua, lint.lua          — đang tắt
vscode/
  settings.json                  — VSCode settings (cross-platform: Mac + Windows)
  keybindings.json               — VSCode keybindings (copy vào User/keybindings.json)
```

> Chi tiết đầy đủ từng file/plugin: xem `CLAUDE.md`.

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
