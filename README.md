# Neovim Config — _david

Config Neovim cá nhân dựa trên [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), chạy được ở **hai môi trường**:

- **Terminal Neovim** — full plugin stack (LSP, Telescope, Treesitter, blink.cmp, flash.nvim...)
- **VSCode + vscode-neovim** — mini.ai + mini.surround + mini.move + flash.nvim + keymaps qua `vscode.action()`

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
keymaps.md                      — danh sách toàn bộ keymaps (BOTH / TER / VSC)
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
    vscode.lua                  — VSCode keymaps (VSCode only)
  kickstart/plugins/            — optional plugins (bật ở Section 10 của init.lua)
vscode/
  settings.json                 — VSCode settings (cross-platform: Mac + Windows)
  keybindings.json              — VSCode keybindings (copy vào User/keybindings.json)
```

## Keymaps nổi bật

> Xem đầy đủ tại [`keymaps.md`](keymaps.md)

### Cả hai môi trường

| Phím | Mô tả |
|---|---|
| `<leader>j` | Flash jump |
| `gh` / `gl` | Di chuyển line/selection sang trái/phải |
| `gj` / `gk` | Di chuyển line/selection xuống/lên |
| `sa` + motion + char | Mini.surround: thêm surround |
| `sd` + char | Mini.surround: xóa surround |
| `sr` + old + new | Mini.surround: thay surround |
| `yaf` / `yif` | Yank around/inside function (treesitter) |
| `yac` / `yic` | Yank around/inside class (treesitter) |

### Terminal

| Phím | Mô tả |
|---|---|
| `\` | Focus Neo-tree (từ editor) / trở về editor (từ Neo-tree) |
| `<leader>e` | Mở / đóng Neo-tree |
| `<leader>ee` | Focus vào Neo-tree (mở nếu đang đóng); `Ctrl+H` để quay lại editor |
| `s` / `S` | Flash jump / Flash treesitter |
| `<leader>sf` | Telescope tìm file |
| `<leader>sg` | Telescope grep |
| `gd` / `gk` / `grn` | LSP: definition / hover / rename |
| `<leader>f` | Format file |
| `<C-s>` | Lưu file |
| `<leader>tt` | Toggle terminal bottom (toggleterm) |
| `<leader>cc` | Toggle Claude Code terminal |
| `<leader>cs` | Gửi selection đến Claude (visual) |
| `<leader>cp` / `<leader>cP` | CodeSnap: copy / lưu ảnh code (visual) |
| `<leader>ic` / `<leader>iC` | Hiện / ẩn kích thước import (JS/TS) |

### VSCode (vscode-neovim)

| Phím | Mô tả |
|---|---|
| `C-c` / `C-x` / `C-v` | Copy / Cut / Paste (VSCode native) |
| `C-z` | Undo (VSCode native) |
| `C-g` | Go to line |
| `<Up>` / `<Down>` | Di chuyển line/selection lên/xuống (mini.move) |
| `C-f` / `C-S-f` | Tìm trong file / Tìm trong tất cả file |
| `gd` / `grn` / `gra` | LSP: definition / rename / code action |
| `<leader>f` | Format document |
| `<leader>sl` | Đổi language mode |
| `<leader>th` / `<leader>te` | Toggle inlay hints / Toggle Error Lens |
| `<leader>e` / `<leader>ee` / `<leader>es` | Toggle sidebar / Explorer / Search |
| `<leader>by` / `<leader>bp` | Yank all / Paste đè toàn file |
| `<leader>c` (visual) | Block comment |
| `<leader>gps` / `<leader>gpl` | Git push / pull (terminal) |
| `<leader>gl` / `<leader>gh` / `<leader>gm` | Git log / history / tạo PR |
| `<leader>ff` | Find It Faster |

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
