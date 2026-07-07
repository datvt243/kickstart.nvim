# Neovim Config — _david

Config Neovim cá nhân dựa trên [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), chạy được ở **hai môi trường**:

- **Terminal Neovim** — full plugin stack (LSP, Telescope, Treesitter, blink.cmp, flash.nvim...)
- **VSCode + vscode-neovim** — keymaps qua `vscode.action()`, jump bằng jumpy

## Yêu cầu

- Neovim stable mới nhất
- `git`, `make`, `ripgrep`, `fd`
- [Nerd Font](https://www.nerdfonts.com/) (đặt `vim.g.have_nerd_font = true` trong `init.lua`)
- Node.js (cho một số LSP server)

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
```

## Cấu trúc

```
init.lua                        — options, keymaps chung, vim.pack hooks
lua/
  custom/plugins/
    completion.lua              — blink.cmp + LuaSnip
    dashboard.lua               — dashboard-nvim
    format.lua                  — conform.nvim
    lsp.lua                     — nvim-lspconfig + Mason + fidget
    telescope.lua               — Telescope fuzzy finder
    treesitter.lua              — nvim-treesitter
    ui.lua                      — mini.nvim, flash.nvim, tokyonight, gitsigns...
    vscode.lua                  — VSCode keymaps (VSCode only)
  kickstart/plugins/            — optional plugins (bật ở Section 10 của init.lua)
```

## Keymaps nổi bật

### Terminal

| Phím | Mô tả |
|---|---|
| `s` / `S` | Flash jump (2 ký tự / treesitter) |
| `<leader>sf` | Telescope tìm file |
| `<leader>sg` | Telescope grep |
| `gd` / `gk` / `grn` | LSP: definition / hover / rename |
| `<leader>f` | Format file |
| `<C-s>` | Lưu file |

### VSCode (vscode-neovim)

| Phím | Mô tả |
|---|---|
| `s` / `S` | Jumpy word / line jump |
| `C-c/x/v` | Copy / Cut / Paste |
| `C-z` / `C-g` | Undo / Go to line |
| `C-f` / `C-S-f` | Tìm trong file / Tìm trong tất cả file |
| `gd` / `grn` / `gra` | LSP: definition / rename / code action |
| `<leader>f` | Format document |
| `<leader>th` / `<leader>te` | Toggle inlay hints / Toggle Error Lens |
| `<leader>e` / `<leader>ee` / `<leader>es` | Toggle sidebar / Explorer / Search |
| `<leader>by` / `<leader>bp` | Yank all / Paste đè toàn file |
| `<leader>c` (visual) | Block comment |
| `<leader>gps` / `<leader>gpl` | Git push / pull (terminal) |
| `<leader>gl` / `<leader>gh` / `<leader>gm` | Git log / history / tạo PR |
| `<leader>gcb` / `<leader>gfh` | New branch / File history |
| `<leader>ff` | Find It Faster |

## VSCode — Extensions cần cài

| Extension | ID |
|---|---|
| vscode-neovim | `asvetliakov.vscode-neovim` |
| Which Key | `vspacecode.whichkey` |
| Find It Faster | `TomiTurtinen.find-it-faster` |
| Fuzzy Search | `jacobdufault.fuzzy-search` |
| Jumpy | `wmaurer.vscode-jumpy` |
| Bookmarks | `alefragnani.Bookmarks` |
| Harpoon | `tobias-z.vscode-harpoon` |
| Project Manager | `alefragnani.project-manager` |

> Disable `vscodevim.vim` nếu đã cài: `code --disable-extension vscodevim.vim`

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
