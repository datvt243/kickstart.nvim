#!/usr/bin/env bash
# health.sh — kiểm tra nhanh Neovim config bằng headless (không cần mở Neovim).
# 3 bước: [1] load config bắt lỗi startup  [2] parse toàn bộ .lua  [3] :checkhealth lọc ERROR.
#
# Dùng:   ./scripts/health.sh
# Exit:   0 nếu sạch; khác 0 nếu có ERROR / parse fail (dùng được trong pre-commit / CI).
#
# Ghi chú cross-platform: đây là script bash cho macOS/Linux/WSL/git-bash. Trên Windows
# thuần (cmd/powershell) không chạy trực tiếp — dùng câu lệnh headless tương đương:
#   nvim --headless "+checkhealth" "+w health.txt" +qa

set -uo pipefail

# Thư mục config = parent của scripts/ (chạy được từ bất kỳ cwd nào)
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$CONFIG_DIR" || exit 1

if ! command -v nvim >/dev/null 2>&1; then
  echo "✗ không tìm thấy 'nvim' trong PATH"
  exit 127
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
fail=0

# Chuyển path kiểu MSYS (/tmp/...) sang path Windows native (C:\...) khi chạy git-bash trên Windows,
# vì nvim.exe không hiểu path MSYS. macOS/Linux không có cygpath → trả path nguyên vẹn (no-op).
to_native() {
  if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else printf '%s' "$1"; fi
}

ERR_PAT='E[0-9]+:|Error detected|Error executing|stack traceback'

# ── [1/3] Load config headless, bắt lỗi startup ──────────────────────────────
echo "[1/3] load config..."
load_out="$(nvim --headless "+qa" 2>&1)"
if printf '%s\n' "$load_out" | grep -qE "$ERR_PAT"; then
  echo "  ✗ FAIL — lỗi khi load config:"
  printf '%s\n' "$load_out" | grep -E "$ERR_PAT" | sed 's/^/    /'
  fail=1
else
  echo "  ✓ OK"
fi

# ── [2/3] Parse toàn bộ .lua (luac -p: chỉ compile, không chạy) ───────────────
echo "[2/3] parse .lua..."
if command -v luac >/dev/null 2>&1; then
  n=0
  bad=0
  # Process substitution (không phải pipe) để n/bad giữ giá trị sau vòng lặp
  while IFS= read -r f; do
    n=$((n + 1))
    if ! err="$(luac -p "$f" 2>&1)"; then
      echo "  ✗ $f"
      printf '%s\n' "$err" | sed 's/^/      /'
      bad=$((bad + 1))
    fi
  done < <(find init.lua lua -name '*.lua')
  if [ "$bad" -eq 0 ]; then
    echo "  ✓ OK ($n files)"
  else
    echo "  ✗ FAIL ($bad/$n files)"
    fail=1
  fi
else
  # Không có luac (thường gặp trên Windows) → dùng chính nvim để parse-check:
  # loadfile() compile file thành bytecode nhưng KHÔNG chạy, tương đương `luac -p`. nvim luôn có sẵn.
  echo "  (không có luac — fallback dùng nvim loadfile)"
  cat > "$TMP/parsecheck.lua" <<'LUA'
local bad = 0
local files = vim.fn.split(vim.fn.glob('lua/**/*.lua'), '\n')
table.insert(files, 'init.lua')
for _, f in ipairs(files) do
  local ok, err = loadfile(f)
  if not ok then
    bad = bad + 1
    io.stderr:write('  x ' .. f .. '\n      ' .. tostring(err) .. '\n')
  end
end
print(#files)
os.exit(bad == 0 and 0 or 1)
LUA
  if parse_out="$(nvim --headless -l "$(to_native "$TMP/parsecheck.lua")" 2>&1)"; then
    echo "  ✓ OK ($(printf '%s' "$parse_out" | tail -1) files)"
  else
    printf '%s\n' "$parse_out" | grep -v '^[0-9]*$'
    echo "  ✗ FAIL — parse lỗi"
    fail=1
  fi
fi

# ── [3/3] checkhealth ────────────────────────────────────────────────────────
echo "[3/3] checkhealth..."
nvim --headless "+checkhealth" "+w! $(to_native "$TMP/health.txt")" +qa >/dev/null 2>&1
if [ -s "$TMP/health.txt" ]; then
  # Bỏ dòng legend ("... should be treated as ...") để không đếm nhầm
  body="$(grep -viE 'should be treated' "$TMP/health.txt")"
  errs="$(printf '%s\n' "$body" | grep -cE 'ERROR' || true)"
  warns="$(printf '%s\n' "$body" | grep -cE 'WARNING' || true)"
  echo "  → $errs ERROR, $warns WARNING"
  if [ "$errs" -gt 0 ]; then
    printf '%s\n' "$body" | grep -nE 'ERROR' | sed 's/^/    /'
    fail=1
  fi
else
  echo "  ✗ FAIL — checkhealth không tạo được output"
  fail=1
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "DONE ✓ — không có lỗi"
else
  echo "DONE ✗ — có lỗi, xem chi tiết ở trên"
fi
exit "$fail"
