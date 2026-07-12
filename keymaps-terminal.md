# Keymaps — Terminal Neovim

> **Legend:**
> - `BOTH` — cũng hoạt động ở VSCode (xem `keymaps-vscode.md`)
> - `TER` — Terminal Neovim only
> - Mode: `n`=Normal `v`=Visual `i`=Insert `x`=Visual/block `o`=Operator `t`=Terminal

---

## Di chuyển cursor

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `j` / `k` | n | BOTH | Di chuyển theo visual line (không bỏ qua wrap). Có count (`5j`) thì dùng j/k thật |
| `}` / `{` | n | BOTH | Nhảy paragraph kế / trước, tự căn giữa màn hình |
| `B` | n | BOTH | Ngắt dòng tại cursor, không vào insert mode |

---

## Scroll (neoscroll.nvim)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `Ctrl+U` / `Ctrl+D` | n, v | TER | Scroll nửa trang lên/xuống, có animation |
| `Ctrl+B` / `Ctrl+F` | n, v | TER | Scroll cả trang lên/xuống, có animation |
| `Ctrl+Y` / `Ctrl+E` | n, v | TER | Scroll 1 dòng lên/xuống, có animation |
| `zt` / `zz` / `zb` | n, v | TER | Căn dòng hiện tại lên đầu/giữa/cuối màn hình, có animation |

---

## Buffer

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `Shift+H` | n | BOTH | Qua buffer trước |
| `Shift+L` | n | BOTH | Qua buffer tiếp |
| `<leader><leader>` | n | TER | Tìm buffer đang mở (Telescope) |
| `<leader>bq` | n | BOTH | Đóng buffer hiện tại (TER: về buffer dùng gần nhất, hết buffer thì mở Dashboard) |
| `<leader>bn` | n | BOTH | Mở buffer mới (file trống) |
| `<leader>by` | n | BOTH | Yank toàn bộ nội dung file vào clipboard |

---

## Lưu file

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `Ctrl+S` | n, i | BOTH | Lưu file (insert mode thoát ra Normal sau khi lưu) |

---

## Indent & di chuyển dòng

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `Tab` | v | BOTH | Tăng indent, giữ nguyên selection |
| `Shift+Tab` | v | BOTH | Giảm indent, giữ nguyên selection |
| `Ctrl+J` / `Ctrl+K` | v | BOTH | Dời dòng / selection xuống / lên |
| `Alt+J` / `Alt+K` | n | BOTH | Dời dòng hiện tại xuống / lên |
| `gh` / `gl` | n, v | BOTH | Di chuyển dòng / selection sang trái / phải (mini.move) |
| `gj` / `gk` | n, v | BOTH | Di chuyển dòng / selection xuống / lên (mini.move) |

---

## Window / Split

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `Ctrl+H` / `Ctrl+L` | n | TER | Focus window trái / phải |
| `Ctrl+J` / `Ctrl+K` | n | TER | Focus window dưới / trên |
| `Ctrl+←` / `Ctrl+→` | n | TER | Focus window trái / phải (alias phím mũi tên; cần tắt Mission Control Ctrl+←/→ trong System Settings) |
| `Ctrl+↓` / `Ctrl+↑` | n | TER | Focus window dưới / trên (alias phím mũi tên) |

---

## Neo-tree

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `\` | n | TER | Từ editor: focus + reveal Neo-tree. Từ Neo-tree: trả focus về editor |
| `<leader>e` | n | TER | Mở / đóng Neo-tree |
| `<leader>ee` | n | TER | Focus vào cửa sổ Neo-tree (mở nếu đang đóng), không reveal file |
| `Ctrl+H` | n | TER | Từ Neo-tree: quay lại editor (window nav chuẩn, đã có sẵn) |

---

## Flash jump

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>j` | n, x, o | BOTH | Flash jump đến bất kỳ vị trí |
| `s` | n, x, o | TER | Flash jump (sneak style) |
| `S` | n, x | TER | Flash treesitter (chọn node syntax xung quanh cursor) |
| `r` | o | TER | Flash remote operator (vd: `yr{ab}` yank từ xa) |
| `<leader>.` | n, x | TER | Flash fuzzy jump |

---

## Paste thông minh (paste đè text object)

> Clipboard **không bị mất** khi paste đè — dùng black hole register `"_`.

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>piq` | n | BOTH | Paste vào trong quote gần nhất (`'` hoặc `"`) |
| `<leader>paq` | n | BOTH | Paste xung quanh quote gần nhất |
| `<leader>piB` | n | BOTH | Paste vào trong `{}` |
| `<leader>paB` | n | BOTH | Paste xung quanh `{}` |
| `<leader>pib` | n | BOTH | Paste vào trong `()` |
| `<leader>pab` | n | BOTH | Paste xung quanh `()` |
| `<leader>pit` | n | BOTH | Paste vào trong HTML/XML tag |
| `<leader>pat` | n | BOTH | Paste xung quanh HTML/XML tag |

---

## Tìm kiếm (Telescope)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>sf` | n | TER | Tìm file trong project |
| `<leader>sg` | n | TER | Live grep toàn project |
| `<leader>sw` | n, v | TER | Grep từ dưới cursor |
| `<leader>sd` | n | TER | Tìm diagnostics |
| `<leader>sh` | n | TER | Tìm trong help tags |
| `<leader>sk` | n | TER | Tìm keymaps |
| `<leader>sc` | n | TER | Tìm commands |
| `<leader>ss` | n | TER | Chọn Telescope picker |
| `<leader>sr` | n | TER | Resume lần tìm trước |
| `<leader>s.` | n | TER | File gần đây (oldfiles) |
| `<leader>sn` | n | TER | Tìm file trong Neovim config |
| `<leader>sp` | n | TER | Danh sách project (project.nvim) |
| `<leader>/` | n | TER | Fuzzy search trong buffer hiện tại |
| `<leader>s/` | n | TER | Grep trong các file đang mở |
| `gf` | n | TER | Fuzzy search trong file (alias, giống `<leader>/`) |
| `gF` | n | TER | Fuzzy search toàn workspace (alias, giống `<leader>sg`) |

---

## LSP

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `gd` | n | TER | Goto definition |
| `grd` | n | TER | Goto definition (Telescope) |
| `grr` | n | TER | Goto references (Telescope) |
| `gri` | n | TER | Goto implementation (Telescope) |
| `grt` | n | TER | Goto type definition (Telescope) |
| `grD` | n | TER | Goto declaration |
| `gk` | n | TER | Hover documentation |
| `grn` | n | TER | Rename symbol |
| `gra` | n, x | TER | Code action |
| `gO` | n | TER | Document symbols |
| `gW` | n | TER | Workspace symbols |
| `<leader>th` | n | TER | Toggle Inlay Hints |
| `<leader>qq` | n | TER | Mở danh sách diagnostic |

---

## Trouble (diagnostics/quickfix/loclist/LSP refs)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>xx` | n | TER | Toggle diagnostics (toàn workspace) |
| `<leader>xX` | n | TER | Toggle diagnostics (chỉ buffer hiện tại) |
| `<leader>xs` | n | TER | Toggle symbols |
| `<leader>xr` | n | TER | Toggle LSP references/definitions |
| `<leader>xl` | n | TER | Toggle location list |
| `<leader>xq` | n | TER | Toggle quickfix list |

---

## Goto Preview (peek definition, editable — goto-preview.nvim)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `gp` | n | TER | Peek definition trong floating window (edit được, giống VSCode Peek) |
| `gpt` | n | TER | Peek type definition |
| `gpi` | n | TER | Peek implementation |
| `gpD` | n | TER | Peek declaration |
| `gpr` | n | TER | Peek references |
| `gP` | n | TER | Đóng tất cả preview window đang mở (từ bất kỳ đâu) |
| `Esc` | n | TER | Đóng preview (chỉ khi cursor đang ở trong preview window) |

---

## Format

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>qf` | n, v | TER | Format current file / selection (conform.nvim) |
| `<leader>qF` | n, v | TER | Format current file with... (chọn formatter) |
| `<leader>qc` | n | TER | Change language mode (đổi filetype) |

---

## Import Cost (file JS/TS/JSX/TSX)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>ic` | n | TER | Hiển thị kích thước (KB) từng import (vim-import-cost) |
| `<leader>iC` | n | TER | Xóa hiển thị kích thước import |

---

## CodeSnap

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>cp` | v | TER | Chụp ảnh selection, copy vào clipboard (codesnap.nvim) |
| `<leader>cP` | v | TER | Chụp ảnh selection, lưu ra file (nhập đường dẫn) |

---

## Autocomplete (blink.cmp)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `Ctrl+Y` | i | TER | Chấp nhận completion |
| `Ctrl+Space` | i | TER | Mở menu / mở docs |
| `Ctrl+N` / `Ctrl+P` | i | TER | Item tiếp / trước trong menu |
| `Ctrl+E` | i | TER | Đóng menu |
| `Ctrl+K` | i | TER | Toggle signature help |
| `Tab` / `Shift+Tab` | i | TER | Di chuyển trong snippet (LuaSnip) |

---

## Mini.surround

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `sa` + motion + char | n | BOTH | Thêm surround (vd: `saiw)` wrap word trong `()`) |
| `sd` + char | n | BOTH | Xóa surround (vd: `sd'` xóa `'`) |
| `sr` + old + new | n | BOTH | Thay surround (vd: `sr)'` đổi `)` thành `'`) |

---

## Mini.ai — Text objects

> Dùng với operator `y`, `d`, `c`, `v`...

| Object | Env | Mô tả |
|---|---|---|
| `af` / `if` | BOTH | Around / inside function (treesitter) |
| `ac` / `ic` | BOTH | Around / inside class (treesitter) |
| `a)` `i)` `a]` `i]` `a}` `i}` | BOTH | Around / inside `()` `[]` `{}` |
| `a'` `i'` `a"` `i"` | BOTH | Around / inside quotes |
| `aa` / `ia` | BOTH | Around / inside argument |
| `aa` (next) | BOTH | Around next object (config: `around_next = 'aa'`) |

---

## Terminal

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>tt` | n, t | TER | Toggle terminal bottom (toggleterm.nvim) |
| `Esc Esc` | t | TER | Thoát terminal mode về Normal |

---

## Git — Lệnh cơ bản

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>gs` | n | TER | Git status (floating window, đóng bằng `q`/`Esc`) |
| `<leader>ga` | n | TER | Git add all (`git add -A`) |
| `<leader>gc` | n | TER | Git commit (nhập message qua prompt) |
| `<leader>gps` | n | TER | Git push |
| `<leader>gpl` | n | TER | Git pull |

---

## Git — Gitsigns

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `]c` / `[c` | n | TER | Nhảy đến hunk tiếp / trước |
| `<leader>hs` | n, v | TER | Stage hunk |
| `<leader>hr` | n, v | TER | Reset hunk |
| `<leader>hS` | n | TER | Stage toàn bộ buffer |
| `<leader>hR` | n | TER | Reset toàn bộ buffer |
| `<leader>hp` | n | TER | Preview hunk (popup) |
| `<leader>hi` | n | TER | Preview hunk inline |
| `<leader>hb` | n | TER | Blame dòng hiện tại (full) |
| `<leader>hd` | n | TER | Diff so với index |
| `<leader>hD` | n | TER | Diff so với commit trước |
| `<leader>hq` | n | TER | Quickfix list hunks (file hiện tại) |
| `<leader>hQ` | n | TER | Quickfix list hunks (toàn repo) |
| `<leader>tb` | n | TER | Toggle blame line |
| `<leader>tw` | n | TER | Toggle word diff |
| `ih` | o, x | TER | Text object: chọn hunk |

---

## Git — Diffview (panel file đã đổi, giống VSCode Source Control)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>gv` | n | TER | Mở panel diffview: liệt kê tất cả file đã đổi, chọn file để xem diff |
| `<leader>gV` | n | TER | Đóng panel diffview |
| `<leader>gh` | n | TER | Xem lịch sử thay đổi (log + diff) của file hiện tại |
| `<leader>gH` | n | TER | Xem lịch sử thay đổi (log + diff) toàn bộ repo |
| `Esc` | n | TER | Đóng toàn bộ Diffview (từ buffer diff, file panel, hoặc file history panel) |

---

## Claude Code

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>cc` | n | TER | Toggle Claude Code terminal |
| `<leader>cf` | n | TER | Focus vào Claude Code terminal |
| `<leader>cs` | v | TER | Gửi selection đến Claude |
| `<leader>cs` | n | TER | Add file (từ neo-tree/tree explorer) vào context |
| `<leader>ca` | n | TER | Accept diff Claude đề xuất |
| `<leader>cd` | n | TER | Deny diff |
| `<leader>cm` | n | TER | Chọn model Claude |

---

## Developer & Misc

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>n` | n | BOTH | Tắt highlight tìm kiếm |
| `Esc` | n | BOTH | Tắt highlight tìm kiếm |
| `<leader>y` | n | BOTH | Xem tất cả registers |
