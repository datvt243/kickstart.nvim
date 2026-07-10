# CLAUDE.md — Neovim Config (_david)

## Quy tắc làm việc

- **Chỉ push code khi được yêu cầu rõ ràng.** Commit xong thì dừng, không tự push.
- **Mỗi lần thay đổi keymap bất kỳ, phải update `keymaps.md`.**

## Tổng quan

Đây là config Neovim cá nhân dựa trên kickstart.nvim, chạy được ở **hai môi trường**:

- **Terminal Neovim** — full plugin stack
- **VSCode với vscode-neovim** (`asvetliakov.vscode-neovim`) — mini.ai + mini.surround + mini.move + flash.nvim + guess-indent; các lệnh editor gọi qua `vscode.action()`

## Cấu trúc file

```
init.lua                        — options, keymaps chung, vim.pack hooks, load plugins
lua/
  custom/plugins/               — plugin files (tự động load bởi init.lua)
    init.lua                    — auto-loader: require toàn bộ .lua trong thư mục
    completion.lua              — blink.cmp + LuaSnip (terminal)
    dashboard.lua               — dashboard-nvim: màn hình chào (terminal)
    format.lua                  — conform.nvim: formatter (terminal)
    lsp.lua                     — nvim-lspconfig + Mason + fidget (terminal)
    telescope.lua               — Telescope fuzzy finder (terminal)
    treesitter.lua              — nvim-treesitter (terminal)
    claudecode.lua              — Claude Code integration (terminal)
    noice.lua                   — noice.nvim: floating cmdline + notifications (terminal)
    project.lua                 — project.nvim: auto-detect root + Telescope picker (terminal)
    terminal.lua                — toggleterm.nvim: terminal nhỏ ở bottom (terminal)
    ui.lua                      — mini.nvim (ai, surround, move), flash.nvim, which-key, tokyonight... (cả hai)
    vscode.lua                  — VSCode keymaps qua vscode.action() (VSCode only)
  kickstart/plugins/            — optional plugins (bỏ comment ở Section 10 để bật)
    autopairs.lua               — [BẬT] tự đóng ngoặc
    debug.lua                   — DAP debugger
    gitsigns.lua                — [BẬT] git keymaps đầy đủ
    indent_line.lua             — indent guides
    lint.lua                    — linter
    neo-tree.lua                — [BẬT] file explorer nâng cao
  health.lua                    — kiểm tra sức khoẻ config
```

## init.lua — Cấu trúc sections

| Section | Nội dung | Môi trường |
|---|---|---|
| 1 | Options + keymaps chung | Cả hai |
| 2 | vim.pack build hooks (PackChanged) | Terminal only |
| — | `require 'custom.plugins'` — load toàn bộ plugin files | — |
| 10 | Optional plugins (kickstart/plugins/) | Terminal only |

> Sections 3–9 đã được tách ra thành các file riêng trong `lua/custom/plugins/`.

## Pattern quan trọng

### Phát hiện môi trường
```lua
local is_vscode = vim.g.vscode ~= nil   -- dùng trong ui.lua (phục vụ cả 2 môi trường)
```

### Guard cho file terminal-only (early return)
```lua
if vim.g.vscode ~= nil then return end  -- đặt ở đầu file, trước mọi code khác
```

### Guard cho file VSCode-only
```lua
if vim.g.vscode == nil then return end  -- ví dụ: vscode.lua
```

### Gọi VSCode command
```lua
local vscode = require 'vscode'
local function act(cmd) return function() vscode.action(cmd) end end
-- Hoặc dùng helper shorthand trong vscode.lua:
local function n(key, cmd, desc) vim.keymap.set('n', key, act(cmd), { desc = desc }) end
n('gd', 'editor.action.revealDefinition', 'Goto definition')
```

### Plugin manager
```lua
-- vim.pack là plugin manager tích hợp sẵn (không dùng lazy.nvim)
local function gh(repo) return 'https://github.com/' .. repo end
vim.pack.add { gh 'user/repo' }

-- Cập nhật:       :PackUpdate
-- Xem trạng thái: :lua vim.pack.update(nil, { offline = true })
```

## Tìm kiếm nhanh (gõ `/###`)

Các marker `###` nằm rải rác trong các file plugin:

| Marker | File | Nội dung |
|---|---|---|
| `### KEYMAPS CHUNG` | `init.lua` | j/k, {/}, buffer, save, indent, move lines, splits |
| `### MINI.AI` | `ui.lua` | text objects: af/if (function), ac/ic (class), treesitter |
| `### MINI.SURROUND` | `ui.lua` | thêm/xóa/thay surround |
| `### MINI.MOVE` | `ui.lua` | di chuyển line/selection: gh/gj/gk/gl + Up/Down |
| `### FLASH.NVIM` | `ui.lua` | jump: `<leader>j` (cả hai), s/S/r/`<leader>.` (terminal) |
| `### TELESCOPE KEYMAPS` | `telescope.lua` | tìm file, grep, buffer |
| `### LSP KEYMAPS` | `lsp.lua` | gd, gk, grn, gra |
| `### BLINK.CMP KEYMAPS` | `completion.lua` | autocomplete |
| `### FORMAT KEYMAP` | `format.lua` | `<leader>f` |
| `### CLAUDE CODE` | `claudecode.lua` | toggle terminal, send selection, accept/deny diff |
| `### PROJECT` | `project.lua` | `<leader>sp` → danh sách project |
| `### TERMINAL KEYMAPS` | `terminal.lua` | `<leader>tt` → toggle terminal |
| `### JUMP` | `vscode.lua` | flash.nvim dùng chung (xem ui.lua) |
| `### SYSTEM SHORTCUTS` | `vscode.lua` | C-c/x/v/z → VSCode native; C-g go to line |
| `### FILE & SEARCH` | `vscode.lua` | C-p, C-f, C-S-f, leader sf/sg/ff/fs |
| `### LSP / CODE ACTIONS` | `vscode.lua` | gd, gr, gk, grn, gra |
| `### FORMAT & DIAGNOSTICS` | `vscode.lua` | leader f, q, th, te |
| `### RENAME / REFACTOR` | `vscode.lua` | leader r, leader ; (v), leader c (v) |
| `### BUFFER / EDITOR` | `vscode.lua` | leader b{q,n,y,p} |
| `### SIDEBAR & UI` | `vscode.lua` | leader e, ee, es |
| `### PANE / WINDOW FOCUS` | `vscode.lua` | C-h/l/j/k, leader w{h,l,k,j} |
| `### TERMINAL` | `vscode.lua` | leader tf/tn/tk |
| `### GIT` | `vscode.lua` | leader g{d,a,c,gps,gpl,k,cb,ob,fh,gl,gh,gm...} |
| `### BOOKMARKS` | `vscode.lua` | leader m{t,e,n,p,l,L,C,A} |
| `### HARPOON` | `vscode.lua` | leader h{p,a,e} |
| `### PROJECT MANAGER` | `vscode.lua` | leader p{l,L,e,r} |

## VSCode — Extensions cần thiết

| Extension | ID | Mục đích |
|---|---|---|
| vscode-neovim | `asvetliakov.vscode-neovim` | Neovim thật nhúng vào VSCode |
| Which Key | `vspacecode.whichkey` | `\` → menu gợi ý keymaps |
| Find It Faster | `TomiTurtinen.find-it-faster` | leader ff/fF/fs/fS |
| Fuzzy Search | `jacobdufault.fuzzy-search` | leader / |
| Bookmarks | `alefragnani.Bookmarks` | leader m* |
| Harpoon | `tobias-z.vscode-harpoon` | leader h* |
| Project Manager | `alefragnani.project-manager` | leader p* |

> **Jump:** Dùng `flash.nvim` (Neovim plugin) thay Jumpy — `<leader>j`. Jumpy conflict với vscode-neovim do hook `type` command.

> **Lưu ý:** Phải disable `vscodevim.vim` nếu đã cài — hai extension conflict với nhau.
> Chạy: `code --disable-extension vscodevim.vim`

> **Which Key:** trigger `\` được đặt trong `keybindings.json` (không phải Lua) để
> vspacecode.whichkey hoạt động đúng với vscode-neovim.

## Thêm LSP server mới

Mở `lua/custom/plugins/lsp.lua`, tìm `local servers = {`, thêm vào:
```lua
local servers = {
  ts_ls = {},
  pyright = {},   -- thêm mới
  -- ...
}
```
Mason sẽ tự cài khi khởi động lại Neovim.

## Thêm formatter mới

Mở `lua/custom/plugins/format.lua`, tìm `formatters_by_ft`:
```lua
formatters_by_ft = {
  python = { 'black' },  -- thêm mới
  -- ...
}
```

## Bật optional plugin

Bỏ comment ở Section 10 trong `init.lua`:
```lua
require 'kickstart.plugins.indent_line'
```
Rồi khởi động lại Neovim.

## Format code Lua

```bash
~/.local/share/nvim/mason/bin/stylua init.lua lua/**/*.lua
```
