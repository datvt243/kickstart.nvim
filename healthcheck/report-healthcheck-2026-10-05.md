# Health Check Report — 2026-10-05

**Môi trường:** macOS 26.5.2 (Darwin arm64), Neovim v0.12.2, chạy qua zsh `./scripts/health.sh`.

Kết quả chạy `./scripts/health.sh`. Chi tiết WARNING lấy thêm bằng `nvim --headless "+checkhealth" "+w! <file>" +qa` (script xoá file tạm sau khi chạy nên không đọc lại được từ script).

## Kết quả tổng: PASS (0 ERROR)

- **Bước 1** (load config): OK
- **Bước 2** (parse `.lua`): OK (49 files)
- **Bước 3** (`:checkhealth`): 0 ERROR, 36 WARNING

## WARNING đáng chú ý (liên quan config)

Không có. Các warning config ở lần chạy trước trong ngày (44 WARNING) đã được sửa ở commit `0e8a6a1` (merge `051678e`):

- **`vim.lsp` — `'gopls' is not executable`**: `lsp.lua` chỉ khai báo `gopls` khi máy có `go`.
- **`blink.cmp` — `blink_cmp_fuzzy lib is not downloaded/built`**: `coding/blink-cmp.lua` đổi `fuzzy.implementation` sang `'prefer_rust_with_warning'` (tự tải lib prebuilt, fallback Lua).
- **`render-markdown` — parser `latex` / `utftex`, `latex2text`**: `ui/render-markdown.lua` đặt `latex = { enabled = false }`.
- **`noice` — parser `regex` chưa cài**: thêm `regex` vào `parsers` trong `treesitter/treesitter.lua`.
- **`noice` — cần `snacks.nvim` hoặc `nvim-notify`**: `ui/noice.lua` cài thêm `rcarriga/nvim-notify`.
- **Lỗi startup phát sinh khi bật blink Rust** — `error loading module 'blink_cmp_fuzzy' from file '.../codesnap.nvim/lua/libs/mac-aarch64_generator.so'`: codesnap.nvim (upstream) nối path lib không có `?` vào `package.cpath`. `tools/codesnap.lua` bọc `load_generator` để khôi phục `cpath` sau khi load. Nên report lên repo codesnap.nvim.

Còn lại, cố ý không xử lý:

- **`goto-preview` — `logger.nvim is not installed`**: dependency tuỳ chọn chỉ cho logging nâng cao; `rmagatti/logger.nvim` có 12★ nên không thêm.
- **`blink.cmp` — `Some providers may show up as "disabled"...`**: thông báo, không phải lỗi.

## Bỏ qua (nhiễu môi trường, không liên quan config)

Thiếu `hg` (diffview); Mason thiếu Go, Composer, javac/java, julia; provider Node (`neovim` npm), Perl (`Neovim::Ext`, không có perl), Python (`import neovim`), Ruby (`neovim-ruby-host`); 21 cảnh báo `Unknown filetype` từ filetypes mặc định của lspconfig; Nvim 0.12.5 đã có (đang dùng 0.12.2).
