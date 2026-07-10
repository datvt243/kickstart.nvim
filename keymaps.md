# Keymaps — Neovim Config

> **Legend:**
> - `BOTH` — hoạt động ở cả Terminal và VSCode
> - `TER` — Terminal Neovim only
> - `VSC` — VSCode (vscode-neovim) only
> - Mode: `n`=Normal `v`=Visual `i`=Insert `x`=Visual/block `o`=Operator `t`=Terminal

---

## Di chuyển cursor

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `j` / `k` | n | BOTH | Di chuyển theo visual line (không bỏ qua wrap). Có count (`5j`) thì dùng j/k thật |
| `}` / `{` | n | BOTH | Nhảy paragraph kế / trước, tự căn giữa màn hình |
| `B` | n | BOTH | Ngắt dòng tại cursor, không vào insert mode |

---

## Buffer

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `Shift+H` | n | BOTH | Qua buffer trước |
| `Shift+L` | n | BOTH | Qua buffer tiếp |
| `<leader><leader>` | n | TER | Tìm buffer đang mở (Telescope) |
| `<leader>bq` | n | BOTH | Đóng buffer hiện tại |
| `<leader>bn` | n | BOTH | Mở buffer mới (file trống) |
| `<leader>by` | n | BOTH | Yank toàn bộ nội dung file vào clipboard |
| `<leader>bp` | n | VSC | Paste đè toàn bộ nội dung file |

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
| `Tab` | n | VSC | Indent lines |
| `Shift+Tab` | n | VSC | Outdent lines |
| `Ctrl+J` / `Ctrl+K` | v | BOTH | Dời dòng / selection xuống / lên |
| `Alt+J` / `Alt+K` | n | BOTH | Dời dòng hiện tại xuống / lên |
| `gh` / `gl` | n, v | BOTH | Di chuyển dòng / selection sang trái / phải (mini.move) |
| `gj` / `gk` | n, v | BOTH | Di chuyển dòng / selection xuống / lên (mini.move) |
| `<Up>` / `<Down>` | n, v | VSC | Di chuyển dòng / selection lên / xuống (mini.move alias) |

---

## Window / Split

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>v` | n | TER | Split dọc |
| `<leader>S` | n | TER | Split ngang |
| `Ctrl+H` / `Ctrl+L` | n | TER | Focus window trái / phải |
| `Ctrl+J` / `Ctrl+K` | n | TER | Focus window dưới / trên |
| `Ctrl+H` / `Ctrl+L` | n | VSC | Focus pane trái / phải |
| `Ctrl+J` / `Ctrl+K` | n | VSC | Dời dòng xuống / lên (VSCode action) |
| `<leader>wh` / `<leader>wl` | n | VSC | Focus window trái / phải |
| `<leader>wk` / `<leader>wj` | n | VSC | Focus window trên / dưới |
| `<leader><Left>` / `<leader><Right>` | n | VSC | Thu nhỏ / phóng to view |
| `Ctrl+Shift+J` | — | VSC | Toggle panel (keybindings.json) |

---

## Neo-tree (Terminal only)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `\` | n | TER | Từ editor: focus + reveal Neo-tree. Từ Neo-tree: trả focus về editor |
| `<leader>e` | n | TER | Mở / đóng Neo-tree |

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

## Tìm kiếm (Telescope — Terminal only)

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

---

## Tìm kiếm (VSCode only)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `Ctrl+P` | n | VSC | Quick Open file |
| `Ctrl+F` | n | VSC | Tìm trong file hiện tại |
| `Ctrl+Shift+F` | n | VSC | Tìm trong tất cả file |
| `<leader>sf` | n | VSC | Quick Open file |
| `<leader>sg` | n | VSC | Tìm trong tất cả file |
| `<leader>/` | n | VSC | Fuzzy search trong file hiện tại |
| `<leader>/` | v | VSC | Fuzzy search selection |
| `<leader>ff` | n | VSC | Find It Faster: tìm file (fzf) |
| `<leader>fF` | n | VSC | Find It Faster: tìm file + filetype |
| `<leader>fs` | n | VSC | Find It Faster: tìm trong file |
| `<leader>fS` | n | VSC | Find It Faster: tìm trong file + type |
| `<leader>fr` | n | VSC | Find & Replace trong files |

---

## LSP (Terminal only)

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
| `<leader>q` | n | TER | Mở danh sách diagnostic |

---

## LSP (VSCode only)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `gd` | n | VSC | Goto definition |
| `gD` | n | VSC | Goto declaration |
| `gp` | n | VSC | Peek definition |
| `gr` | n | VSC | Goto references |
| `gR` | n | VSC | References panel |
| `gi` | n | VSC | Goto implementation |
| `gt` | n | VSC | Peek type definition |
| `gs` | n | VSC | Document symbols |
| `gS` | n | VSC | Workspace symbols |
| `gk` | n | VSC | Hover docs |
| `gf` | n | VSC | Fuzzy search |
| `grd` | n | VSC | Goto definition |
| `grr` | n | VSC | Goto references |
| `gri` | n | VSC | Goto implementation |
| `grt` | n | VSC | Goto type definition |
| `grn` | n | VSC | Rename |
| `grD` | n | VSC | Goto declaration |
| `gra` | n, x | VSC | Code action / Quick fix |
| `<leader>r` | n | VSC | Rename symbol |
| `<leader>;` | v | VSC | Refactor |
| `<leader>th` | n | VSC | Toggle Inlay Hints |
| `<leader>te` | n | VSC | Toggle Error Lens |
| `<leader>q` | n | VSC | Mở Problems panel |

---

## Format

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>f` | n, v | TER | Format buffer / selection (conform.nvim) |
| `<leader>f` | n, v | VSC | Format document (VSCode formatter) |

---

## Autocomplete (blink.cmp — Terminal only)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `Ctrl+Y` | i | TER | Chấp nhận completion |
| `Ctrl+Space` | i | TER | Mở menu / mở docs |
| `Ctrl+N` / `Ctrl+P` | i | TER | Item tiếp / trước trong menu |
| `Ctrl+E` | i | TER | Đóng menu |
| `Ctrl+K` | i | TER | Toggle signature help |
| `Tab` / `Shift+Tab` | i | TER | Di chuyển trong snippet (LuaSnip) |

---

## Mini.surround (cả hai)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `sa` + motion + char | n | BOTH | Thêm surround (vd: `saiw)` wrap word trong `()`) |
| `sd` + char | n | BOTH | Xóa surround (vd: `sd'` xóa `'`) |
| `sr` + old + new | n | BOTH | Thay surround (vd: `sr)'` đổi `)` thành `'`) |

---

## Mini.ai — Text objects (cả hai)

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

## Sidebar & UI (VSCode only)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>e` | n | VSC | Mở / đóng sidebar |
| `<leader>ee` | n | VSC | Explorer panel |
| `<leader>es` | n | VSC | Search panel |
| `<leader>sl` | n | VSC | Đổi language mode |
| `<leader>>` | n | VSC | Command palette |
| `Ctrl+G` | n | VSC | Go to line |

---

## Terminal (Terminal Neovim only)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>tt` | n, t | TER | Toggle terminal bottom (toggleterm.nvim) |
| `Esc Esc` | t | TER | Thoát terminal mode về Normal |

---

## Terminal (VSCode only)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>tf` | n | VSC | Focus terminal |
| `<leader>tn` | n | VSC | Terminal mới |
| `<leader>tk` | n | VSC | Kill terminal |
| `Ctrl+Shift+N` | — | VSC | Terminal mới (khi đang focus terminal) |
| `Ctrl+Shift+K` | — | VSC | Kill terminal (khi đang focus terminal) |
| `Esc Esc` | t | TER | Thoát terminal mode về Normal |

---

## Git — Gitsigns (Terminal only)

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

## Git (VSCode only — cần GitLens + multiCommand)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>gd` | n | VSC | Git diff (view changes) |
| `<leader>ga` | n | VSC | Git add all |
| `<leader>gc` | n | VSC | Git commit |
| `<leader>gps` | n | VSC | Git push |
| `<leader>gpl` | n | VSC | Git pull |
| `<leader>gk` | n | VSC | Git checkout |
| `<leader>gcb` | n | VSC | Tạo branch mới |
| `<leader>gu` | n | VSC | Git unstage |
| `<leader>guc` | n | VSC | Undo commit |
| `<leader>goc` | n | VSC | Mở file changes |
| `<leader>gos` | n | VSC | Mở staged changes |
| `<leader>gob` | n | VSC | Mở file trên remote (GitLens) |
| `<leader>gfh` | n | VSC | File history (GitLens) |
| `<leader>gl` | n | VSC | Git log |
| `<leader>gh` | n | VSC | Git history (GitLens) |
| `<leader>gm` | n | VSC | Tạo Pull Request |
| `<leader>gcp` | n | VSC | Cherry pick |
| `<leader>gca` | n | VSC | Cherry pick abort |
| `<leader>gdb` | n | VSC | Xóa branch |
| `<leader>gdr` | n | VSC | Xóa remote branch |
| `<leader>gDc` | n | VSC | Discard file hiện tại |
| `<leader>gDa` | n | VSC | Discard tất cả |
| `<leader>gtc` | n | VSC | Tạo tag |
| `<leader>gtp` | n | VSC | Push tags |
| `<leader>gtd` | n | VSC | Xóa tag |

---

## Bookmarks (VSCode only — extension: alefragnani.Bookmarks)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>mt` | n | VSC | Toggle bookmark |
| `<leader>me` | n | VSC | Toggle bookmark có label |
| `<leader>mn` | n | VSC | Nhảy đến bookmark tiếp |
| `<leader>mp` | n | VSC | Nhảy đến bookmark trước |
| `<leader>ml` | n | VSC | Danh sách bookmark (file hiện tại) |
| `<leader>mL` | n | VSC | Danh sách bookmark (tất cả file) |
| `<leader>mC` | n | VSC | Xóa tất cả bookmark (file hiện tại) |
| `<leader>mA` | n | VSC | Xóa tất cả bookmark (tất cả file) |

---

## Harpoon (VSCode only — extension: tobias-z.vscode-harpoon)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>ha` | n | VSC | Thêm file vào Harpoon |
| `<leader>hp` | n | VSC | Quick pick danh sách Harpoon |
| `<leader>he` | n | VSC | Chỉnh sửa danh sách Harpoon |

---

## Project Manager (VSCode only — extension: alefragnani.project-manager)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>pl` | n | VSC | Danh sách project (cửa sổ mới) |
| `<leader>pL` | n | VSC | Danh sách project |
| `<leader>pe` | n | VSC | Chỉnh sửa project |
| `<leader>pr` | n | VSC | Refresh projects |

---

## Settings (VSCode only)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>su` | n | VSC | Settings UI |
| `<leader>sj` | n | VSC | Settings JSON |
| `<leader>sku` | n | VSC | Keybindings UI |
| `<leader>skj` | n | VSC | Keybindings JSON |
| `<leader>st` | n | VSC | Chọn color theme |
| `<leader>si` | n | VSC | Chọn icon theme |

---

## Claude Code (Terminal only)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>cc` | n | TER | Toggle Claude Code terminal |
| `<leader>cs` | v | TER | Gửi selection đến Claude |
| `<leader>ca` | n | TER | Accept diff Claude đề xuất |
| `<leader>cd` | n | TER | Deny diff |

---

## Developer & Misc

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>n` | n | BOTH | Tắt highlight tìm kiếm |
| `Esc` | n | BOTH | Tắt highlight tìm kiếm |
| `<leader>y` | n | BOTH | Xem tất cả registers |
| `<leader>c` | v | VSC | Block comment |
| `<leader>Dr` | n | VSC | Reload VSCode window |
| `\` (Which Key) | n | VSC | Mở Which Key menu (keybindings.json) |
