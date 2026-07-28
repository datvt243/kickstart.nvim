Kiểm tra sức khỏe Neovim config bằng headless (không mở Neovim), rồi báo cáo gọn kết quả.

## Cách chạy

Chạy script có sẵn ở repo:

```bash
./scripts/health.sh
```

Script làm 3 bước và tự set exit code (0 = sạch, khác 0 = có lỗi):
1. Load config headless — bắt lỗi startup.
2. `luac -p` parse toàn bộ `.lua` dưới `init.lua` + `lua/`.
3. `:checkhealth` — đếm ERROR / WARNING, in chi tiết ERROR nếu có.

## Báo cáo

Sau khi chạy, tóm tắt cho tôi:
- **Kết quả tổng**: PASS hay FAIL (theo exit code).
- Số **ERROR** và số **WARNING**.
- Nếu có ERROR: liệt kê từng cái kèm plugin/mục nào, và đề xuất hướng xử lý.
- WARNING chỉ cần nêu cái nào **thực sự liên quan đến config** (bỏ qua nhiễu môi trường như thiếu Go/Java/Python provider, `luac` chưa cài, bản Neovim mới hơn...), đừng liệt kê dài dòng.

## Tạo report file (khi tôi yêu cầu "tạo report" / "lưu report")

Ghi kết quả thành file Markdown trong thư mục `healthcheck/`, đặt tên theo ngày:

```
healthcheck/report-healthcheck-YYYY-MM-DD.md
```

- Ngày lấy theo ngày chạy thực tế. Nếu file cùng ngày đã tồn tại: hỏi tôi ghi đè hay tạo bản mới (thêm hậu tố `-2`, `-3`...).
- Lấy môi trường thật để điền (đừng đoán): `nvim --version | head -1`, và OS/arch (`uname -sm` trên Unix, hoặc `ver` trên Windows).
- **Chỉ ghi file, không sửa config** trừ khi tôi yêu cầu riêng.

### Format chuẩn (theo đúng khuôn `report-healthcheck-2026-07-24.md`)

````markdown
# Health Check Report — YYYY-MM-DD

**Môi trường:** <OS + version> (<arch>), Neovim <version>, chạy qua <cách chạy: zsh / Git Bash `bash scripts/health.sh` ...>.

Kết quả chạy `./scripts/health.sh`.<ghi chú nếu phải chạy thủ công bước nào và vì sao>

## Kết quả tổng: <PASS | FAIL> (<n> ERROR)

- **Bước 1** (load config): OK | FAIL
- **Bước 2** (parse `.lua`): OK (<n> files) | FAIL (<chi tiết>) | bỏ qua (<lý do>)
- **Bước 3** (`:checkhealth`): <n> ERROR, <n> WARNING

## ERROR (<n>) — `<plugin/mục>`
<!-- Bỏ hẳn section này nếu 0 ERROR. Mỗi ERROR một khối như dưới. -->

```
<trích log verbatim, giữ nguyên stack traceback nếu có>
```

**Nguyên nhân:** <giải thích ngắn, gồm cả OS-specific nếu chỉ xảy ra trên 1 OS>.

**Lỗi config hay không:** <có → nêu file cần sửa | không → upstream (bug plugin) / môi trường (thiếu tool), giải thích tại sao không sửa từ phía config>.

**Đề xuất:** <hướng xử lý cụ thể>.

## WARNING đáng chú ý (liên quan config)
<!-- Chỉ những warning ĐỘNG tới config/behaviour thật. Không có thì ghi "Không có." -->

- **`<mục>`**: <mô tả + hướng xử lý>.

## Bỏ qua (nhiễu môi trường, không liên quan config)

<gộp thành 1 đoạn ngắn: liệt kê gọn các warning môi trường — thiếu Go/Java/Python/Ruby provider, `fd`/`hg`/`wget`, treesitter parser tuỳ chọn, bản Neovim mới hơn... — không diễn giải dài>.
````

### Nguyên tắc phân loại (quan trọng — đừng để lẫn)

- **ERROR/WARNING là lỗi config** ⇒ nêu rõ file cần sửa (vd formatter thiếu trong `ensure_installed`, path hardcode). Đây là mục cần hành động.
- **Upstream** (bug trong code plugin, vd thiếu nil-guard) ⇒ ghi rõ là không sửa từ config, nên report lên repo plugin.
- **Môi trường** (thiếu binary/toolchain, shim `.cmd` trên Windows, Mason chưa cài xong) ⇒ cho vào mục "Bỏ qua" hoặc ghi cách cài, KHÔNG gọi là lỗi config.

## Nếu script không chạy được

- Nếu `./scripts/health.sh` không tồn tại hoặc không có quyền chạy, thử `bash scripts/health.sh`; vẫn không được thì báo tôi (có thể file bị xóa).
- Nếu đang ở môi trường không chạy được bash (vd Windows thuần cmd/powershell), chạy trực tiếp — ghi ra file trong thư mục hiện tại (đừng dùng `/tmp`, nvim.exe không hiểu path đó):
  ```
  nvim --headless "+checkhealth" "+w! nvim-health.txt" +qa
  ```
  rồi đọc `nvim-health.txt`, lọc dòng `ERROR` / `WARNING` và báo cáo như trên. Xoá file sau khi xong.

Không sửa gì trừ khi tôi yêu cầu — command này chỉ để kiểm tra và báo cáo.
