# Build hook (PackChanged) spawn `npm`/`make` lỗi ENOENT trên Windows

**Status: ĐÃ RESOLVE** ✅ (fix trong `init.lua`, verify hành vi trên macOS + phân tích tĩnh Windows)

**File liên quan:** `init.lua` (Section 2 — `run_build` + autocmd `PackChanged`)

**Chỉ xảy ra trên Windows.** Phát hiện khi rà soát toàn bộ plugin cho môi trường Windows (2026-07-14).

## Hiện tượng

`run_build()` chạy build step sau khi plugin được cài/cập nhật bằng:
```lua
vim.system({ 'npm', 'install', '--production' }, { cwd = ... }):wait()
```
Trên Windows, `npm` thực chất là `npm.cmd` (batch), `make` là `make.exe`. libuv (`uv_spawn` → `CreateProcess`)
**không chạy trực tiếp file `.cmd`/`.bat`**, chỉ chạy được `.exe`. Vì `vim.fn.executable('npm')` vẫn trả về
`1` (npm.cmd nằm trên PATH qua PATHEXT) nên nhánh build được vào, nhưng `vim.system{'npm', ...}` spawn thất
bại với **ENOENT** → lỗi lan lên autocmd `PackChanged` → Neovim báo "Error executing autocommand" mỗi lần
cài/update `vim-import-cost` (khi máy có Node/npm).

`make` (telescope-fzf-native) ít gặp hơn vì `make.exe` là exe thật, nhưng nếu là wrapper `.cmd` cũng dính
cùng lỗi. LuaSnip `make install_jsregexp` đã được guard sẵn `has('win32') ~= 1` nên không ảnh hưởng.

## Root cause

`vim.system` (libuv spawn) trên Windows không phân giải `.cmd`/`.bat` như shell. Muốn chạy batch/script
trên PATH phải đi qua `cmd.exe /c`.

## Cách fix đã áp

Trong `run_build`, khi ở Windows thì bọc lệnh qua `cmd.exe /c`:
```lua
local function run_build(name, cmd, cwd)
  -- Windows: npm là npm.cmd (batch); libuv CreateProcess không chạy trực tiếp .cmd/.bat (chỉ .exe)
  -- nên spawn 'npm' sẽ ENOENT → route qua cmd.exe /c để chạy được cả .cmd lẫn .exe trên PATH.
  if vim.fn.has 'win32' == 1 then cmd = vim.list_extend({ 'cmd.exe', '/c' }, cmd) end
  ...
end
```
- Chỉ đổi hành vi trên Windows (`has('win32')==1`); macOS/Linux giữ nguyên → không regression.
- Bọc cả `make` lẫn `npm` đều an toàn (`cmd.exe /c make` / `cmd.exe /c npm ...`).

## Đã verify

- **macOS**: nhánh Windows không chạy → `run_build` giữ nguyên; startup/khởi động sạch, không lỗi.
- **Windows (phân tích tĩnh)**: `cmd.exe /c npm install --production` chạy được npm.cmd, hết ENOENT.
  Không thể chạy máy Windows thật ở đây nên chưa test end-to-end; cần xác nhận lại trên máy Windows khi
  cài/update `vim-import-cost` (`:PackUpdate`).
