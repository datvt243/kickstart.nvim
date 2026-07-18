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

## Nếu script không chạy được

- Nếu `./scripts/health.sh` không tồn tại hoặc không có quyền chạy, thử `bash scripts/health.sh`; vẫn không được thì báo tôi (có thể file bị xóa).
- Nếu đang ở môi trường không chạy được bash (vd Windows thuần), chạy trực tiếp:
  ```bash
  nvim --headless "+checkhealth" "+w /tmp/nvim-health.txt" +qa
  ```
  rồi đọc `/tmp/nvim-health.txt`, lọc dòng `ERROR` / `WARNING` và báo cáo như trên.

Không sửa gì trừ khi tôi yêu cầu — command này chỉ để kiểm tra và báo cáo.
