Tìm plugin Neovim theo tên hoặc theo chức năng, rồi báo cáo gọn kèm số sao GitHub + độ phổ biến để tôi chọn.

## Đầu vào

`$ARGUMENTS` — có thể là:
- **Tên plugin cụ thể**: vd `telescope`, `oil.nvim` → tra thẳng repo đó + gợi ý vài lựa chọn thay thế cùng nhóm.
- **Chức năng cần tìm**: vd `file explorer`, `fuzzy finder`, `git diff`, `smooth scroll` → liệt kê các plugin phổ biến làm việc đó.

Nếu `$ARGUMENTS` trống, hỏi tôi cần plugin làm gì trước khi tìm.

## Cách tìm (bắt buộc lấy số liệu THẬT, không đoán)

1. **Tìm ứng viên**: dùng `WebSearch` (vd `"neovim <chức năng> plugin"`, `awesome-neovim <chức năng>`) và/hoặc `WebFetch` trang awesome-neovim để gom 3–6 repo ứng viên.
2. **Lấy số liệu từng repo qua `gh`** (chuẩn nhất, real-time):
   ```bash
   gh repo view <owner>/<repo> --json stargazerCount,pushedAt,updatedAt,description,licenseInfo,archivedAt
   ```
   - **Số sao** (`stargazerCount`) — BẮT BUỘC nêu (rule trong CLAUDE.md: giới thiệu plugin mới phải kèm star + độ phổ biến; số thay đổi theo thời gian nên phải fetch, đừng nhớ áng chừng).
   - **Lần commit gần nhất** (`pushedAt`) — để biết còn được maintain hay đã bỏ.
   - **Đã archived chưa** (`archivedAt` khác null = ngừng phát triển → cảnh báo).
   - Nếu không có `gh`/không mạng: nói rõ là chưa lấy được số liệu thật, ĐỪNG bịa số sao.

## Báo cáo (bảng gọn, không lan man)

| Plugin | ⭐ Sao | Cập nhật gần nhất | Tóm tắt | Dual-env | Cross-OS |
|---|---|---|---|---|---|
| `owner/repo` | 12.3k | 2026-07 | 1 dòng plugin làm gì | Both / Terminal-only / VSCode-only | có cảnh báo gì không |

Sau bảng, thêm:
- **Đề xuất**: chọn 1 cái + lý do (hợp gu config này: nền kickstart, quản lý bằng `vim.pack`, không lazy.nvim).
- **Độ phổ biến/uy tín**: ngoài số sao, nêu nếu là plugin "chuẩn mực" trong hệ sinh thái (được nhắc nhiều, nằm trong awesome-neovim, tác giả có nhiều plugin uy tín...).

## Bắt buộc đánh giá 2 trục (theo working rules của config)

Với plugin được đề xuất, nêu rõ trước khi tôi cài:

1. **VSCode vs Terminal** — plugin chạy được ở cả hai, hay chỉ terminal (cần guard `if vim.g.vscode ~= nil then return end`), hay chỉ VSCode. Neo-tree/telescope/lualine... là terminal-only; mini.*/flash là cả hai.
2. **Windows vs macOS** — có rủi ro OS-specific không: path separator `\` vs `/`, hardcode `~/`·`/tmp`, tool ngoài chỉ có 1 OS (`make`, `xmllint`, tree-sitter CLI...), spawn `.cmd`/`.bat` qua `vim.system`. Nếu có → ghi chú cần guard `vim.fn.has 'win32'`.

## Không tự cài

Command này chỉ **tìm + báo cáo + đề xuất**. Chỉ khi tôi xác nhận "cài đi" mới tạo file plugin (theo cấu trúc `lua/custom/plugins/<nhóm>/`, pattern `local config = {...}` + `vim.pack.add { gh '...' }` như các file khác), rồi verify sạch trên cả 2 trục + chạy `./scripts/health.sh`.
