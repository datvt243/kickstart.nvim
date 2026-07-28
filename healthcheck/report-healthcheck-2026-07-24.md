# Health Check Report — 2026-07-24

**Môi trường:** Windows 10 Pro 10.0.19045 (x86_64-pc-windows-msvc), Neovim v0.12.3, chạy qua Git Bash (`bash scripts/health.sh`).

Kết quả chạy `./scripts/health.sh` (bước 3 chạy thủ công qua scratchpad vì `/tmp` không tồn tại trên Windows nvim binary).

## Kết quả tổng: FAIL (1 ERROR)

- **Bước 1** (load config): OK
- **Bước 2** (parse `.lua`): bỏ qua — thiếu `luac` trong PATH (không phải lỗi thật)
- **Bước 3** (`:checkhealth`): **1 ERROR, 46 WARNING**

## ERROR (1) — `nvim-treesitter`

```
Failed to run healthcheck for "nvim-treesitter" plugin. Exception:
...vim/version.lua:179: attempt to index local 'version' (a nil value)
```

**Nguyên nhân:** healthcheck của plugin gọi `tree-sitter --version` để kiểm tra bản CLI. Trên máy này, `tree-sitter` trong PATH (`C:\nvm4w\nodejs\tree-sitter`) chỉ có shim `.cmd`/`.ps1`, không có `.exe`. `vim.fn.system({...})` (job-spawn) không chạy được file `.cmd` trực tiếp → output không parse ra version → `ts.version = nil` → nvim-treesitter gọi `vim.version.ge(nil, ...)` và crash vì thiếu kiểm tra nil.

Đây là **bug ở code của plugin nvim-treesitter** (không check nil trước khi so sánh version), không phải lỗi trong config — không ảnh hưởng chức năng thật: mục `vim.treesitter` vẫn PASS, các parser (c/lua/markdown/vim/...) vẫn load bình thường.

**Đề xuất:** không cần sửa gì trong config; có thể báo lỗi lên repo nvim-treesitter, hoặc bỏ qua vì chỉ ảnh hưởng phần hiển thị `:checkhealth`.

## WARNING đáng chú ý (liên quan config)

- **`vim.lsp`**: `gopls`, `lua-language-server`, `stylua` — "not executable", dù cả 3 đều được cấu hình trong `lsp.lua`/`conform.lua`. Kiểm tra `nvim-data/mason/bin/` chỉ thấy `typescript-language-server` và `vscode-eslint-language-server` được cài — 3 server kia **chưa được Mason cài**. → Mở Neovim, chạy `:Mason` để cài thủ công, hoặc restart để trigger auto-install.
- **`conform`**: `prettierd` không có trong PATH — formatter cho JS/TS/... sẽ không chạy nếu được dùng.
- **`blink.cmp`**: thư viện native `blink_cmp_fuzzy` chưa được build/tải — completion vẫn chạy nhưng dùng fallback chậm hơn thay vì fuzzy matcher native.
- **`claudecode`**: `'claude --version'` fail dù CLI được tìm thấy tại `C:\nvm4w\nodejs\claude` — có thể do CLI cũng là shim `.cmd` gặp vấn đề spawn tương tự; không chặn plugin hoạt động (WebSocket server vẫn chạy OK).

## Bỏ qua (nhiễu môi trường, không liên quan config)

15 warning của `mason` (thiếu Go/Java/Python/Ruby/PHP/Julia/wget/7z toolchain — không dùng các ngôn ngữ này), 6 warning `vim.provider` (thiếu Node/Perl/Python/Ruby provider), `vim.health` (có bản Nvim 0.12.4 mới hơn), `diffview` (thiếu `hg`), `telescope` (thiếu `fd`), `noice`/`render-markdown` (thiếu vài treesitter parser tuỳ chọn như regex/bash/html/latex/yaml).

## Cập nhật xử lý (2026-07-29)

Rà lại toàn bộ, tách rõ **lỗi config** (sửa được) và **upstream/môi trường** (không thuộc config):

**Đã sửa trong config:**

- **`prettierd`/`stylua` "not executable"** → **lỗ hổng config thật**: 2 formatter này được `conform.lua` dùng nhưng `ensure_installed` của mason-tool-installer (`lsp.lua`) bỏ trống → Mason không tự cài, máy mới (Windows) thiếu binary. Đã thêm `'stylua'`, `'prettierd'` vào `ensure_installed`. Máy cũ (macOS) tình cờ có sẵn nên không lộ.
- **Bước 2 (luac) bị skip + bước 3 (checkhealth) chạy thủ công trên Windows** → `scripts/health.sh` hardcode giả định Unix: (1) đường dẫn `/tmp/...` của git-bash không được `nvim.exe` hiểu, (2) thiếu `luac`. Đã thêm helper `to_native()` (dùng `cygpath -w` khi có, no-op trên macOS/Linux) cho path truyền vào nvim, và fallback parse-check bằng `nvim -l` + `loadfile()` khi không có luac. Verify trên macOS: không regression; nhánh fallback parse đúng 47 file và bắt được lỗi cú pháp (negative test pass).

**Upstream/môi trường — KHÔNG phải lỗi config, không sửa từ phía config:**

- **ERROR `nvim-treesitter` (`version.lua:179` nil)** → bug upstream: `health.lua:14-19` gọi `vim.fn.system({'tree-sitter','--version'})`; trên Windows `tree-sitter` là shim `.cmd` (libuv không spawn được) → `out` rỗng → `version=nil` → `vim.version.ge(nil,...)` crash (thiếu nil-guard). Chỉ ảnh hưởng hiển thị `:checkhealth`; `vim.treesitter` vẫn PASS, parser vẫn load. Nên report lên repo nvim-treesitter, không hack plugin internals.
- **`gopls`/`lua_ls` not executable** → đã khai báo đúng trong `servers` (`lsp.lua`); chỉ là Mason chưa cài xong lúc chụp report (gopls còn cần Go toolchain). Restart + `:Mason` là xong.
- **`blink.cmp` native fuzzy chưa build, `claudecode` `claude --version` fail** → build-hook/download + spawn `.cmd` shim trên Windows; completion & WebSocket vẫn chạy fallback OK. Môi trường, không chặn chức năng.
