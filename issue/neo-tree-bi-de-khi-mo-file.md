# Mở file/đổi buffer khi đang focus trong neo-tree → file mở đè lên cửa sổ cây thư mục

**Status: ĐÃ RESOLVE** ✅ (fix trong `telescope.lua` + `init.lua`, verify bằng test headless trên macOS)

**File liên quan:** `lua/custom/plugins/telescope.lua`, `init.lua` (Section 1 — khối `### BUFFER`)

**KHÔNG đặc thù OS** — xảy ra trên cả Windows lẫn macOS/Linux. Phát hiện trên Windows (2026-07-29) khi bấm `<leader>sf` lúc con trỏ đang đứng trong neo-tree.

## Hiện tượng

Khi cửa sổ **đang focus là neo-tree** và ta kích hoạt một thao tác "mở file / đổi buffer", file được mở **ngay trong cửa sổ neo-tree**, thay thế cây thư mục (cây "biến" thành file vừa chọn).

Hai nhóm gây lỗi:

1. **Telescope picker** — `<leader>sf` (find_files) và mọi picker khác (`sg`, `so`, `<leader><leader>`, `<C-p>`, `gF`, LSP `grr/grd/gri/grt/gs/gS`, project picker): mặc định Telescope mở file vào cửa sổ đang focus lúc gọi picker.
2. **Map buffer trong `init.lua`** — `<S-h>`/`<S-l>` (`:bprevious`/`:bnext`), `<leader>bn` (`:enew`), `<leader>bq` (đổi buffer + `bdelete`): đều thao tác lên buffer của **cửa sổ hiện tại**, nên bấm khi đang ở neo-tree sẽ nạp buffer vào cửa sổ cây.

## Root cause

Cùng một lớp lỗi: lệnh mở/đổi buffer chạy trên **cửa sổ đang focus**, mà cửa sổ neo-tree lại là window bình thường (chỉ chứa buffer `nofile`, filetype `neo-tree`) nên không tự chặn việc nạp buffer khác vào.

Đã xác nhận bằng test headless: đặt current window là buffer filetype `neo-tree` rồi chạy `:bnext` → filetype cửa sổ chuyển từ `neo-tree` sang file thường (cây bị đè).

## Đã thử / đã loại

- **`winfixbuf = true`** cho cửa sổ neo-tree: chặn được `:bnext`, nhưng có nguy cơ làm hỏng việc neo-tree tự đổi source (filesystem ↔ git_status khi bấm `<leader>eg`) vì cơ chế đó cũng đổi buffer trong chính cửa sổ. → không dùng.

## Fix đã áp

### 1. Telescope (`telescope.lua`) — override `get_selection_window`

Telescope có sẵn API `defaults.get_selection_window = function(picker, entry) return win_id end` (mặc định `return 0` = dùng cửa sổ gốc). Override để: cửa sổ gốc là editor bình thường → giữ nguyên; là neo-tree → nhảy sang cửa sổ editor đầu tiên. Bao trọn **mọi picker** cùng lúc, không phải vá từng keymap.

```lua
local function pick_editor_window(picker)
  local ori = picker and picker.original_win_id
  if ori and vim.api.nvim_win_is_valid(ori) and vim.bo[vim.api.nvim_win_get_buf(ori)].filetype ~= 'neo-tree' then
    return ori
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'neo-tree' then return win end
  end
  return 0 -- chỉ có neo-tree → để Telescope xử lý mặc định
end
-- config = { defaults = { get_selection_window = pick_editor_window }, ... }
```

### 2. Map buffer (`init.lua`) — helper `ensure_editor_win()`

Trước khi chạy `bnext`/`bprevious`/`enew`/đóng buffer, nếu đang ở neo-tree thì nhảy sang cửa sổ editor gần nhất; nếu chỉ có mỗi neo-tree thì **bỏ qua thao tác** (giữ nguyên cây).

```lua
local function ensure_editor_win()
  if vim.bo.filetype ~= 'neo-tree' then return true end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'neo-tree' then
      vim.api.nvim_set_current_win(win)
      return true
    end
  end
  return false
end
```

Áp cho 4 map: `<S-h>`, `<S-l>`, `<leader>bn`, `<leader>bq` (dạng `if ensure_editor_win() then vim.cmd '...' end`).

## Đã verify (test headless, macOS)

- **Telescope**: `pick_editor_window` — gốc-editor trả đúng cửa sổ editor; gốc-neo-tree nhảy sang editor (không phải cửa sổ cây). PASS.
- **Map buffer**: bấm `<S-l>` khi ở neo-tree → cửa sổ cây nguyên vẹn, focus chuyển sang editor, buffer đổi ở editor. Chỉ có mỗi neo-tree → thao tác bị bỏ qua, cây giữ nguyên. PASS.
- `./scripts/health.sh`: 0 ERROR, parse 47 file OK.
- **VSCode**: không load neo-tree (file guard early-return) nên không có filetype `neo-tree` → cả 2 helper luôn đi nhánh "editor bình thường" → **hành vi không đổi**.

## Ghi chú

- Không đổi phím hay mô tả nào → `keymaps-terminal.md`/`keymaps-vscode.md` giữ nguyên.
- `goto-preview` (gp*) mở floating window riêng, `trouble` có logic cửa sổ riêng, `flash`/LSP `gd` là buffer-local (neo-tree không có LSP) → **không dính** lỗi này.
