# Keymaps — VSCode (vscode-neovim)

> **Legend:**
> - `BOTH` — cũng hoạt động ở Terminal Neovim (xem `keymaps-terminal.md`)
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

---

## Window / Split

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `Ctrl+H` / `Ctrl+L` | n | VSC | Focus pane trái / phải |
| `Ctrl+J` / `Ctrl+K` | n | VSC | Dời dòng xuống / lên (VSCode action) |
| `<leader>wh` / `<leader>wl` | n | VSC | Focus window trái / phải |
| `<leader>wk` / `<leader>wj` | n | VSC | Focus window trên / dưới |
| `<leader><Left>` / `<leader><Right>` | n | VSC | Thu nhỏ / phóng to view |
| `Ctrl+Shift+J` | — | VSC | Toggle panel (keybindings.json) |

---

## Flash jump

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>j` | n, x, o | BOTH | Flash jump đến bất kỳ vị trí |

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

## Tìm kiếm

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

## LSP

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
| `<leader>f` | n, v | VSC | Format document (VSCode formatter) |

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

## Sidebar & UI

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>e` | n | VSC | Mở / đóng sidebar |
| `<leader>ee` | n | VSC | Explorer panel |
| `<leader>es` | n | VSC | Search panel |
| `<leader>sl` | n | VSC | Đổi language mode |
| `<leader>>` | n | VSC | Command palette |
| `Ctrl+G` | n | VSC | Go to line |

---

## Terminal

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>tf` | n | VSC | Focus terminal |
| `<leader>tn` | n | VSC | Terminal mới |
| `<leader>tk` | n | VSC | Kill terminal |
| `Ctrl+Shift+N` | — | VSC | Terminal mới (khi đang focus terminal) |
| `Ctrl+Shift+K` | — | VSC | Kill terminal (khi đang focus terminal) |

---

## Git

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

## Bookmarks (extension: alefragnani.Bookmarks)

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

## Harpoon (extension: tobias-z.vscode-harpoon)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>ha` | n | VSC | Thêm file vào Harpoon |
| `<leader>hp` | n | VSC | Quick pick danh sách Harpoon |
| `<leader>he` | n | VSC | Chỉnh sửa danh sách Harpoon |

---

## Project Manager (extension: alefragnani.project-manager)

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>pl` | n | VSC | Danh sách project (cửa sổ mới) |
| `<leader>pL` | n | VSC | Danh sách project |
| `<leader>pe` | n | VSC | Chỉnh sửa project |
| `<leader>pr` | n | VSC | Refresh projects |

---

## Settings

| Phím | Mode | Env | Mô tả |
|---|---|---|---|
| `<leader>su` | n | VSC | Settings UI |
| `<leader>sj` | n | VSC | Settings JSON |
| `<leader>sku` | n | VSC | Keybindings UI |
| `<leader>skj` | n | VSC | Keybindings JSON |
| `<leader>st` | n | VSC | Chọn color theme |
| `<leader>si` | n | VSC | Chọn icon theme |

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
