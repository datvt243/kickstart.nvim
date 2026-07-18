-- smear-cursor.nvim: animate con trỏ với hiệu ứng "smear" (vệt kéo theo)
-- khi di chuyển, giống cursor animation của Neovide nhưng chạy trong terminal.
-- https://github.com/sphamba/smear-cursor.nvim
if vim.g.vscode ~= nil then return end

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'sphamba/smear-cursor.nvim' }

-- ### SMEAR-CURSOR — toàn bộ option kèm giá trị mặc định của plugin.
-- Giữ nguyên default trừ khi muốn tinh chỉnh; chỉ cần đổi dòng tương ứng.
-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
  -- ── Khi nào bật smear ─────────────────────────────────────────────
  -- Smear khi con trỏ nhảy giữa các buffer/window khác nhau
  smear_between_buffers = true,

  -- Smear khi di chuyển sang dòng liền kề (j/k) trong cùng buffer
  smear_between_neighbor_lines = true,

  -- Khoảng cách ngang tối thiểu (số cột) mới bắt đầu smear; 0 = luôn smear
  min_horizontal_distance_smear = 0,

  -- Khoảng cách dọc tối thiểu (số dòng) mới bắt đầu smear; 0 = luôn smear
  min_vertical_distance_smear = 0,

  -- Cho phép smear theo phương ngang
  smear_horizontally = true,

  -- Cho phép smear theo phương dọc
  smear_vertically = true,

  -- Cho phép smear theo đường chéo
  smear_diagonally = true,

  -- Smear khi con trỏ nhảy xuống dòng cmdline (:)
  smear_to_cmd = true,

  -- Vẽ smear cả ở vùng trống khi scroll buffer
  scroll_buffer_space = true,

  -- ── Ký tự / kiểu vẽ ───────────────────────────────────────────────
  -- Dùng ký tự "Legacy Computing" (Unicode 16) để smear nét mảnh, đỡ vuông/thô.
  -- CẦN font hỗ trợ ký tự này; font không có sẽ vẽ vệt thành ô vuông □ (tofu).
  -- Để false = dùng block eighth (▏▎▍▌) mà hầu hết font đều có.
  legacy_computing_symbols_support = false,

  -- Dùng thêm ký tự thanh dọc của bộ Legacy Computing khi smear
  legacy_computing_symbols_support_vertical_bars = false,

  -- Dùng ký tự block chéo để vẽ smear đường chéo mượt hơn
  use_diagonal_blocks = true,

  -- ── Hình dạng con trỏ theo mode ───────────────────────────────────
  -- Vẽ con trỏ đích dạng thanh dọc (|) ở normal mode
  vertical_bar_cursor = false,

  -- Bật smear ở insert mode
  smear_insert_mode = true,

  -- Con trỏ đích dạng thanh dọc khi ở insert mode
  vertical_bar_cursor_insert_mode = true,

  -- Bật smear ở replace mode (R)
  smear_replace_mode = false,

  -- Bật smear ở terminal mode
  smear_terminal_mode = false,

  -- Con trỏ đích dạng thanh ngang (_) khi ở replace mode
  horizontal_bar_cursor_replace_mode = true,

  -- ── Xử lý con trỏ đích ────────────────────────────────────────────
  -- Không bao giờ vẽ smear đè lên vị trí con trỏ đích (tránh nhấp nháy)
  never_draw_over_target = false,

  -- Hack ẩn con trỏ thật tại đích trong lúc animate (chỉ bật nếu bị nhân đôi con trỏ)
  hide_target_hack = false,

  -- Số floating window tối đa giữ lại để tái sử dụng khi vẽ smear
  max_kept_windows = 50,

  -- z-index của floating window vẽ smear (nổi trên hầu hết UI)
  windows_zindex = 300,

  -- Danh sách filetype tắt smear, ví dụ { 'markdown', 'help' }
  filetypes_disabled = {},

  -- ── Thời gian / độ trễ (ms) ───────────────────────────────────────
  -- Khoảng cách giữa mỗi khung hình vẽ; giảm xuống 7ms (~140fps) cho mượt hơn.
  -- Mặc định 17ms ≈ 60fps. Nếu CPU/terminal yếu thấy nặng thì tăng lại 17.
  time_interval = 7,

  -- Tự tắt smear sau N ms không hoạt động; nil = không tự tắt
  delay_disable = nil,

  -- Độ trễ từ khi có event tới lúc bắt đầu smear
  delay_event_to_smear = 1,

  -- Độ trễ sau khi nhấn phím mới bắt đầu smear (gõ nhanh không bị giật)
  delay_after_key = 5,

  -- ── Vật lý animation (normal mode) ────────────────────────────────
  -- Độ "cứng" của đầu con trỏ: cao = đuổi theo đích nhanh (0..1).
  -- Tăng lên 0.8 (mặc định 0.6) để smear nhanh, đỡ bóng đằng sau.
  stiffness = 0.8,

  -- Độ cứng của đuôi vệt: cao = đuôi bám sát, vệt ngắn & tan nhanh (0..1).
  -- Tăng lên 0.6 (mặc định 0.45) để bớt vệt/ô vuông lê phía sau.
  trailing_stiffness = 0.6,

  -- Đầu con trỏ "đoán trước" hướng di chuyển (0..1)
  anticipation = 0.2,

  -- Giảm chấn: cao = ít nảy/dao động hơn (0..1).
  -- Tăng lên 0.95 (mặc định 0.85) để dừng gọn, không dao động.
  damping = 0.95,

  -- Số mũ độ thuôn của đuôi vệt: cao = đuôi nhọn dần
  trailing_exponent = 3,

  -- Ngưỡng khoảng cách (ô) để coi là tới đích và dừng animate.
  -- Tăng lên 0.5 (mặc định 0.1) để dừng sớm hơn -> bóng biến mất nhanh.
  distance_stop_animating = 0.5,

  -- ── Vật lý animation (insert mode) ────────────────────────────────
  -- Độ cứng đầu con trỏ ở insert mode
  stiffness_insert_mode = 0.5,

  -- Độ cứng đuôi vệt ở insert mode
  trailing_stiffness_insert_mode = 0.5,

  -- Giảm chấn ở insert mode
  damping_insert_mode = 0.9,

  -- Số mũ độ thuôn đuôi vệt ở insert mode
  trailing_exponent_insert_mode = 1,

  -- Ngưỡng dừng animate khi con trỏ là thanh dọc
  distance_stop_animating_vertical_bar = 0.875,

  -- ── Hình học đường smear (nâng cao, hiếm khi cần đổi) ──────────────
  -- Độ dốc tối đa vẫn coi là smear ngang
  max_slope_horizontal = (1 / 3) / 1.5,

  -- Độ dốc tối thiểu để coi là smear dọc
  min_slope_vertical = 2 * 1.5,

  -- Sai lệch góc tối đa để dùng block chéo
  max_angle_difference_diagonal = math.pi / 16,

  -- Độ lệch tối đa cho phép khi vẽ đường chéo
  max_offset_diagonal = 0.2,

  -- Độ đậm tối thiểu mới bỏ qua block chéo
  min_shade_no_diagonal = 0.2,

  -- Như trên nhưng cho con trỏ thanh dọc
  min_shade_no_diagonal_vertical_bar = 0.5,

  -- ── Màu sắc & shading ─────────────────────────────────────────────
  -- Số cấp độ đậm nhạt khi tô vệt (nhiều = mượt hơn, nặng hơn)
  color_levels = 16,

  -- Hiệu chỉnh gamma cho blend màu vệt
  gamma = 2.2,

  -- Số mũ gradient dọc theo chiều dài vệt
  gradient_exponent = 1.0,

  -- Màu smear; để nil sẽ lấy theo màu con trỏ GUI. Ví dụ: '#d4d4d4'
  -- cursor_color = '#d4d4d4',

  -- ── Chế độ vẽ "matrix" (fallback khi không dùng block chéo) ────────
  -- Độ đậm tối đa để vẫn dùng chế độ matrix thay vì block đặc
  max_shade_no_matrix = 0.75,

  -- Ngưỡng bật pixel ở chế độ matrix
  matrix_pixel_threshold = 0.7,

  -- Ngưỡng pixel matrix khi con trỏ là thanh dọc
  matrix_pixel_threshold_vertical_bar = 0.25,

  -- Hệ số tối thiểu cho pixel matrix
  matrix_pixel_min_factor = 0.5,

  -- Số mũ giảm "thể tích" vệt theo tốc độ
  volume_reduction_exponent = 0.3,

  -- Hệ số thể tích tối thiểu của vệt
  minimum_volume_factor = 0.7,

  -- Chiều dài tối đa của vệt (số ô)
  max_length = 25,

  -- Chiều dài tối đa của vệt ở insert mode
  max_length_insert_mode = 1,

  -- ── Hiệu ứng hạt (particles) — mặc định tắt, khá nặng ─────────────
  -- Bật hiệu ứng bắn hạt theo vệt con trỏ
  particles_enabled = false,

  -- Số hạt tối đa tồn tại cùng lúc
  particle_max_num = 100,

  -- Độ phân tán vị trí hạt
  particle_spread = 0.5,

  -- Số hạt sinh ra mỗi giây
  particles_per_second = 200,

  -- Số hạt sinh ra trên mỗi đơn vị chiều dài vệt
  particles_per_length = 1.0,

  -- Thời gian sống tối đa của hạt (ms)
  particle_max_lifetime = 300,

  -- Số mũ phân phối thời gian sống của hạt
  particle_lifetime_distribution_exponent = 5,

  -- Vận tốc ban đầu tối đa của hạt
  particle_max_initial_velocity = 10,

  -- Phần vận tốc thừa hưởng từ con trỏ
  particle_velocity_from_cursor = 0.2,

  -- Vận tốc ngẫu nhiên thêm cho hạt
  particle_random_velocity = 100,

  -- Giảm chấn chuyển động của hạt
  particle_damping = 0.2,

  -- Trọng lực kéo hạt rơi
  particle_gravity = 20,

  -- Khoảng cách con trỏ tối thiểu mới bắt đầu bắn hạt
  min_distance_emit_particles = 1.5,

  -- Ngưỡng đổi octant khi vẽ hạt bằng ký tự Braille
  particle_switch_octant_braille = 0.3,

  -- Cho phép vẽ hạt đè lên chữ
  particles_over_text = false,

  -- ── Khác ──────────────────────────────────────────────────────────
  -- Mức log của plugin
  logging_level = vim.log.levels.INFO,
}

require('smear_cursor').setup(config)
