# CLAUDE.md — Neovim Config (_david)

## Tổng quan

Đây là config Neovim cá nhân dựa trên kickstart.nvim, chạy được ở **hai môi trường**:

- **Terminal Neovim** — full plugin stack
- **VSCode với vscode-neovim** (`asvetliakov.vscode-neovim`) — chỉ dùng mini.ai + mini.surround + guess-indent; các lệnh editor gọi qua `vscode.action()`

## Cấu trúc file

```
init.lua                    — file config chính (toàn bộ cấu hình)
lua/
  kickstart/plugins/        — optional plugins (bỏ comment ở Section 10 để bật)
    autopairs.lua
    debug.lua
    gitsigns.lua
    indent_line.lua
    lint.lua
    neo-tree.lua
  custom/                   — plugin cá nhân (tự thêm)
  health.lua                — kiểm tra sức khoẻ config
```

## init.lua — Cấu trúc sections

| Section | Nội dung | Môi trường |
|---|---|---|
| 1 | Options + keymaps chung | Cả hai |
| 2 | vim.pack build hooks | Terminal only |
| 3 | UI plugins: mini.nvim, gitsigns, which-key, tokyonight, flash.nvim | mini: cả hai; còn lại: terminal only |
| 4 | Telescope | Terminal only |
| 5 | LSP + Mason | Terminal only |
| 6 | conform.nvim (format) | Terminal only |
| 7 | blink.cmp + LuaSnip | Terminal only |
| 8 | Treesitter | Terminal only |
| 9 | VSCode keymaps (`vscode.action()`) | VSCode only |
| 10 | Optional plugins (commented out) | Terminal only |

## Pattern quan trọng

### Phát hiện môi trường
```lua
local is_vscode = vim.g.vscode ~= nil   -- đặt ở đầu file, dùng xuyên suốt
```

### Bọc code chỉ chạy ở terminal
```lua
if not is_vscode then do
  -- nội dung
end end
```

### Gọi VSCode command
```lua
local vscode = require 'vscode'
local function act(cmd) return function() vscode.action(cmd) end end
vim.keymap.set('n', 'gd', act 'editor.action.revealDefinition', { desc = '...' })
```

### Plugin manager
```lua
-- vim.pack là plugin manager tích hợp sẵn (không dùng lazy.nvim)
vim.pack.add { 'https://github.com/user/repo' }

-- Cập nhật:       :PackUpdate
-- Xem trạng thái: :lua vim.pack.update(nil, { offline = true })
```

## Tìm kiếm nhanh trong init.lua

Gõ `/###` để nhảy đến các nhóm keymap/motion:

- `### KEYMAPS CHUNG` — j/k, {/}, buffer, save, indent, move lines, splits
- `### MINI.AI` — text objects mở rộng
- `### MINI.SURROUND` — thêm/xóa/thay surround
- `### FLASH.NVIM` — jump nhanh (s, S, r, `<leader>.`)
- `### TELESCOPE KEYMAPS` — tìm file, grep, buffer
- `### LSP KEYMAPS` — gd, gk, grn, gra
- `### BLINK.CMP KEYMAPS` — autocomplete
- `### FORMAT KEYMAP` — `<leader>f`
- `### FILE & SEARCH` *(VSCode)* — C-p, C-f, leader sf/sg
- `### LSP / CODE ACTIONS` *(VSCode)* — gd, gr, gk, grn, gra
- `### TERMINAL` *(VSCode)* — leader tf/tn/tk
- `### GIT` *(VSCode)* — leader g{d,a,c,p,...}
- `### BOOKMARKS` *(VSCode)* — leader m{t,e,n,p,l}
- `### HARPOON` *(VSCode)* — leader h{p,a,e}
- `### PROJECT MANAGER` *(VSCode)* — leader p{l,L,e,r}

## VSCode — Extensions cần thiết

| Extension | ID | Mục đích |
|---|---|---|
| vscode-neovim | `asvetliakov.vscode-neovim` | Neovim thật nhúng vào VSCode |
| Find It Faster | `TomiTurtinen.find-it-faster` | leader ff/fF/fs/fS |
| Fuzzy Search | `jacobdufault.fuzzy-search` | leader / |
| Bookmarks | `alefragnani.Bookmarks` | leader m* |
| Harpoon | `tobias-z.vscode-harpoon` | leader h* |
| Project Manager | `alefragnani.project-manager` | leader p* |

> **Lưu ý:** Phải disable `vscodevim.vim` nếu đã cài — hai extension conflict với nhau.
> Chạy: `code --disable-extension vscodevim.vim`

## Thêm LSP server mới

Mở `init.lua`, tìm `local servers = {` ở Section 5, thêm vào:
```lua
local servers = {
  ts_ls = {},
  pyright = {},   -- thêm mới
  -- ...
}
```
Mason sẽ tự cài khi khởi động lại Neovim.

## Thêm formatter mới

Tìm `formatters_by_ft` ở Section 6:
```lua
formatters_by_ft = {
  python = { 'black' },  -- thêm mới
  -- ...
}
```

## Bật optional plugin

Bỏ comment ở Section 10 trong `init.lua`:
```lua
require 'kickstart.plugins.autopairs'
```
Rồi khởi động lại Neovim.
