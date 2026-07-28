# Health Check Report — 2026-07-29

**Môi trường:** macOS 26.5.2 (25F84) — Darwin arm64, Neovim v0.12.2, chạy qua zsh (`./scripts/health.sh`).

Kết quả chạy `./scripts/health.sh` — cả 3 bước tự động, không phải chạy tay bước nào.

## Kết quả tổng: PASS (0 ERROR)

- **Bước 1** (load config): OK
- **Bước 2** (parse `.lua`): OK (47 files)
- **Bước 3** (`:checkhealth`): **0 ERROR, 24 WARNING**

## WARNING đáng chú ý (liên quan config)

Không có. 24 warning đều là nhiễu môi trường trên macOS (xem mục dưới), không cái nào là lỗi config hay ảnh hưởng hành vi thực tế của config.

## Bỏ qua (nhiễu môi trường, không liên quan config)

- **Provider ngôn ngữ ngoài** (6): Node (`neovim` npm), Perl (`Neovim::Ext`, không có perl), Python (`import neovim` fail), Ruby (`neovim-ruby-host`) — không dùng plugin remote nên không cần.
- **Toolchain chưa cài** (Mason/nhiều mục): Go, Java/`javac`, Julia, Composer/PHP — không viết các ngôn ngữ này. Kéo theo **`gopls` not executable** (đã khai báo đúng trong `lsp.lua`, chỉ chưa chạy được vì thiếu Go toolchain; cài Go rồi restart là hết) và filetype `gotmpl` chưa nhận.
- **`blink_cmp_fuzzy` lib chưa build** — completion vẫn chạy fallback Lua, chỉ chậm hơn fuzzy native; không chặn chức năng.
- **Treesitter parser tuỳ chọn thiếu**: `regex` (highlight cmdline), `utftex`/`latex2text` (render-markdown LaTeX) — không cần cho loại file đang dùng.
- **Tool ngoài thiếu**: `hg` (diffview, không dùng Mercurial). `noice` gợi ý `snacks.nvim`/`nvim-notify` cho route notify — tuỳ chọn, không bắt buộc.
- **Phiên bản/thông tin**: Nvim 0.12.4 mới hơn bản hiện tại 0.12.2; `mason.nvim v2.3.0`; `logger.nvim` không cài; `ABI: unknown` — thuần thông tin, không phải lỗi.

> Lưu ý: report này chạy trên **macOS** nên sạch. Các vấn đề đặc thù Windows (shim `.cmd`, Mason chưa cài xong) ở [report 2026-07-24](report-healthcheck-2026-07-24.md) cần chạy lại `./scripts/health.sh` (nay đã hỗ trợ đủ 3 bước qua `cygpath` + fallback `nvim loadfile`) trên chính máy Windows để xác nhận.
