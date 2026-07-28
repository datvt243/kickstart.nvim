Codesnap windows workarounds
# codesnap.nvim: 2 bug chỉ xảy ra trên Windows, chặn cả require lẫn tính năng chụp ảnh

**Status: ĐÃ RESOLVE** ✅

**File liên quan:** `lua/custom/plugins/tools/codesnap.lua`

**Chỉ xảy ra trên Windows.** Cả 2 bug đều do plugin `codesnap.nvim` giả định môi trường Unix
(path separator `/`, có sẵn toolchain Rust/cargo để build local).

## Bug 1 — crash ngay khi `require('codesnap')`, trước khi chạy bất kỳ lệnh nào

`codesnap/utils/path.lua`'s `dir_name()` tự suy ra thư mục cài đặt của plugin từ
`debug.getinfo(1).source`, nhưng chỉ match path separator `\`. Trên Windows, Neovim trả về
`source` dùng `/`, nên match trả về `nil` → `codesnap/module.lua:15` crash vì concatenate `nil`.
Kết quả: **plugin crash ngay lúc load module**, chưa kịp chạy lệnh nào.

## Bug 2 — `:CodeSnap`/`:CodeSnapSave` lỗi "Failed to load the generator library"

`codesnap/config.lua` luôn gọi `module.load_generator(true)`, tức tìm binary debug build cục bộ
bằng cargo (`generator/target/debug/generator.dll`) thay vì dùng prebuilt release lib mà
`codesnap.nvim` tự tải về từ GitHub Releases. Máy không có sẵn toolchain Rust/cargo/MSVC để build
local → lỗi **"Failed to load the generator library"** mỗi lần gọi `:CodeSnap`/`:CodeSnapSave`.

## Cách fix đã áp dụng (workaround, patch trong config)

Thêm đoạn code trong `codesnap.lua`, chạy **trước** `require('codesnap').setup{}` (bắt buộc, vì cả
2 bug đều xảy ra lúc load module, không phải lazy):

```lua
if vim.fn.has 'win32' == 1 then
  local ok_path, path_utils = pcall(require, 'codesnap.utils.path')
  if ok_path then
    local utils_file = vim.api.nvim_get_runtime_file('lua/codesnap/utils/path.lua', false)[1]
    local utils_dir = utils_file and vim.fn.fnamemodify(utils_file, ':h')
    if utils_dir then path_utils.with_dir_name = function(path) return utils_dir .. '/' .. path end end
  end

  local ok_module, codesnap_module = pcall(require, 'codesnap.module')
  if ok_module then
    local load_generator = codesnap_module.load_generator
    codesnap_module.load_generator = function(_) return load_generator(false) end
  end
end
```

- Bug 1: resolve thư mục plugin qua `vim.api.nvim_get_runtime_file(...)` thay vì tự parse
  `debug.getinfo(1).source` — không phụ thuộc path separator.
- Bug 2: override `load_generator` để luôn gọi `load_generator(false)` (dùng prebuilt release lib
  đã tải sẵn), bỏ qua flag debug mặc định `true`.

## Trạng thái

Đã sửa trong working tree (`git diff` đang pending, chưa commit). Không cần cài thêm compiler/toolchain
nào — chỉ là patch Lua thuần trong config.
