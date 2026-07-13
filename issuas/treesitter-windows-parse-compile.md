# nvim-treesitter: cố compile lại parser mỗi lần khởi động trên Windows thiếu compiler, gây lỗi log

**Status: ĐÃ RESOLVE** ✅ (fix áp trong `treesitter.lua`, verify trên macOS + mô phỏng Windows)

**Phát hiện qua:** `:checkhealth` (2026-07-13)

**File liên quan:** `lua/custom/plugins/treesitter/treesitter.lua`

## ĐÍNH CHÍNH root cause (sau khi đọc source nvim-treesitter branch `main`)

Không phải "install chạy vô điều kiện" — `install.lua:475` **có** skip parser đã cài
(`if not force and vim.list_contains(config.get_installed(), lang) then return true`).
Nguyên nhân thật: `config.get_installed('parsers')` (`config.lua:44-56`) **chỉ quét thư mục
install riêng của nvim-treesitter** (`stdpath('data')/site/parser`), **không quét thư mục parser
bundled của Neovim** (`lib/nvim/parser`). Nên 7 parser Neovim bundle sẵn không bao giờ được coi là
"installed" → mỗi startup lại cố compile lại. Trên Windows thiếu MSVC → compile fail → 11 dòng lỗi
mỗi startup. Ngoài ra FileType autocmd cũng gọi `install():await()` cho từng file → thêm noise mỗi
lần mở file, không chỉ lúc startup.

**Chỉ xảy ra trên Windows.** Nguyên nhân là đặc thù của `tree-sitter-cli` bản Windows (bắt buộc
`cl.exe`/MSVC để build parser) — trên Linux/macOS chỉ cần `cc`/`gcc`/`clang` là đủ, không gặp vấn đề này.

## Hiện tượng

Mỗi lần khởi động nvim (và mỗi lần chạy `:checkhealth`), `require('nvim-treesitter').install(parsers)`
chạy lại không điều kiện, cố tải + compile lại toàn bộ 11 parser trong danh sách:
`bash, c, diff, html, lua, luadoc, markdown, markdown_inline, query, vim, vimdoc`.

## Error message đầy đủ (verbatim từ log)

Trước khi cài `tree-sitter-cli`:
```
[nvim-treesitter/install/html]: Compiling parser
[nvim-treesitter/install/html] error: Error during "tree-sitter build": [string "?"]:324: ENOENT: no such file or directory (cmd): 'tree-sitter'
```

Sau khi cài `tree-sitter-cli` (npm) nhưng chưa có compiler C/C++ thật:
```
[nvim-treesitter/install/luadoc]: Compiling parser
[nvim-treesitter/install/luadoc] error: Error during "tree-sitter build": [string "?"]:326: ENOENT: no such file or directory
```
(lặp lại cho từng parser: bash, c, diff, html, lua, luadoc, markdown, markdown_inline, query, vim, vimdoc)

Thêm 1 lần thấy lỗi phụ khi 2 process cùng ghi vào 1 thư mục tạm:
```
[nvim-treesitter/install/html] error: Could not rename temp: EPERM: operation not permitted:
  C:/Users/DanielVo/AppData/Local/Temp/nvim/tree-sitter-html-tmp/tree-sitter-html-... -> .../tree-sitter-html
```

`:checkhealth` còn phát sinh thêm lỗi phụ (do race condition giữa install async và `vim.pack` health check —
hệ quả phụ của lỗi gốc, chạy song song install async trong lúc checkhealth):
```
Error in command line:
vim.schedule callback: ...neovim/share/nvim/runtime/lua/vim/treesitter.lua:454: Invalid buffer id: 4
stack traceback:
 [C]: in function 'error'
 ...nvim-treesitter/lua/nvim-treesitter/async.lua:230: in function '_finish'
 ...nvim-treesitter/lua/nvim-treesitter/async.lua:301: in function '_resume'
 ...nvim-treesitter/lua/nvim-treesitter/async.lua:318: in function <...async.lua:308>
 [C]: in function 'wait'
 ...neovim/share/nvim/runtime/lua/vim/_async.lua:50: in function 'wait'
 .../vim/pack.lua:520: in function 'async_join_run_wait'
 .../vim/pack.lua:1426: in function 'add_p_data_info'
 .../vim/pack.lua:1484: in function <...pack.lua:1433>
 [C]: in function 'pcall'
 .../vim/pack/health.lua:225: in function 'check_installed_plugin'
 .../vim/pack/health.lua:247: in function 'check_plug_dir'
 .../vim/pack/health.lua:261: in function 'check'
 [string "require("vim.pack.health").check()"]:1: in main chunk
 [C]: in function 'pcall'
 .../vim/health.lua:457: in function '_check'
 [string "<nvim>"]:1: in main chunk
```
 ## Root cause thật sự



Neovim (bản cài hiện tại) **đã bundle sẵn 7/11 parser** trong `Program Files/Neovim/lib/nvim/parser/`:
`c, lua, markdown, markdown_inline, query, vim, vimdoc`.



Đã verify bằng test trực tiếp: mở `init.lua` → `vim.treesitter.get_parser()` = true,
`vim.treesitter.language.add('lua')` = true → **highlighting Lua hoạt động bình thường**,
hoàn toàn không phụ thuộc việc `nvim-treesitter` install thành công hay không.



`nvim-treesitter` chỉ không nhận ra các parser bundled này (nó check thư mục install riêng của nó,
không check runtime parser dir của Neovim core) nên cứ lặp lại việc tải/compile mỗi lần khởi động.



**Chỉ 4 parser thực sự thiếu** (không được Neovim bundle sẵn): `bash`, `diff`, `html`, `luadoc`.



## Đã thử / đã loại



- Cài `tree-sitter-cli` qua `npm install -g tree-sitter-cli` → xong, nhưng compile vẫn lỗi vì thiếu compiler C/C++ thật.
- Cài Zig (`winget install zig.zig`) làm compiler thay thế → **không dùng được**: `tree-sitter-cli` bản Windows
  luôn build parser theo flag kiểu MSVC (`cl.exe`-style: `-nologo -MD -Brepro -std:c11 ... -LD ... /IMPLIB:...`)
  bất kể `CC` trỏ tới đâu. `zig cc` dùng cú pháp gcc/clang nên không tương thích — build "thành công giả"
  nhưng không ra file `.dll`. Đã test trực tiếp với 1 parser mẫu (tree-sitter-lua) để xác nhận.



## Fix đã áp (2026-07-14) — "sạch 100%", không cần cài compiler

Sửa `treesitter.lua`, thêm 2 helper + đổi cả startup lẫn FileType autocmd:

- `parser_available(lang)`: dùng `vim.api.nvim_get_runtime_file('parser/'..lang..'.so', false)` để
  detect parser có sẵn qua **bất kỳ** runtime dir (gồm cả `lib/nvim/parser` bundled lẫn dir nvim-treesitter
  đã cài) — vá đúng chỗ mù của `get_installed()`.
- `can_compile()`: chỉ install khi có CLI `tree-sitter` **và** C compiler thật (`cl` trên Windows;
  `cc`/`clang`/`gcc` trên Unix). Thiếu → bỏ hẳn install, không log lỗi.
- Startup: `install()` chỉ nhận list parser thực sự thiếu (`not parser_available`), và chỉ chạy khi
  `can_compile()`.
- FileType autocmd: parser đã runtime-available → attach thẳng; thiếu + compile được → install rồi attach;
  thiếu + không compile được → `treesitter_try_attach` (no-op an toàn nếu parser không load được).

### Đánh đổi (đúng như đã chọn)

Trên Windows **không có** MSVC: 7 parser bundle (`c, lua, markdown, markdown_inline, query, vim, vimdoc`)
vẫn highlight bình thường; mất TS highlight cho `bash/diff/html/luadoc`. Cài MSVC (`cl.exe`) vào là 4 parser
này tự compile ở lần mở file kế tiếp, không cần sửa lại config.

### Đã verify

- **macOS thật**: load config OK, `:e lua/options.lua` → highlighter active, `language.add('lua')` = true.
  Không đổi hành vi (cả 11 parser đã runtime-available nên không install lại lần nào).
- **Mô phỏng Windows-không-compiler**: source file thật với `has('win32')=1`, `executable('cl')=0`,
  không parser runtime → **0 lần gọi install** ở cả startup lẫn autocmd (hết noise).
- **Mô phỏng Windows-có-`cl`** + 7 parser bundle: startup install **đúng 4 parser thiếu**
  (`bash, diff, html, luadoc`), bỏ qua 7 bundled.



## Hướng giải quyết tạm thời (đề xuất trước mắt, không cần cài thêm gì nặng)



**Sửa `treesitter.lua` để bỏ qua các parser đã bundled sẵn trong Neovim**
(`c, lua, markdown, markdown_inline, query, vim, vimdoc`), chỉ thử cài (hoặc bỏ hẳn) 4 parser
còn thiếu thật sự (`bash, diff, html, luadoc`).



- Hết noise log/lỗi mỗi lần khởi động.
- **Không cần cài compiler nào** (không VS Build Tools, không MSYS2).
- Đánh đổi: mất treesitter highlighting nâng cao cho `.sh`/`.diff`/`.html`/luadoc annotations —
  các phần còn lại (Lua, Markdown, Vim, vimdoc, query — tức đúng loại file của config này) vẫn
  hoạt động bình thường vì đã dùng parser bundle của Neovim, không liên quan đến sửa này.



## Hướng xử lý lâu dài hơn (nếu sau này muốn có đủ cả 11 parser, kể cả bash/diff/html/luadoc)



1. **Cài Visual Studio Build Tools (MSVC `cl.exe`)** qua winget
   (`Microsoft.VisualStudio.2022.BuildTools`, workload C++) — compiler đúng target mà
   `tree-sitter-cli` Windows cần, chạy chắc chắn nhất. Nặng (~2-3GB).



2. **Cài MSYS2 + mingw-w64 gcc** qua winget (`MSYS2.MSYS2`, `pacman -S mingw-w64-x86_64-gcc`) —
   nhẹ hơn, nhưng rủi ro không chạy được vì `tree-sitter-cli` build cho target `windows-msvc`
   chứ không phải `gnu`.
