-- VSCode keymaps: map VSCode command vào Neovim keymaps để dùng workflow quen thuộc (VSCode only)
-- Bao gồm: file/search, LSP/code actions, format, git, bookmarks, harpoon, project manager, settings
-- Extension cần cài: xem bảng "VSCode — Required extensions" trong CLAUDE.md
-- Keymap nổi bật: <leader>sf/sg tìm file/grep, gr* LSP actions, <leader>g* git, <leader>m* bookmarks,
-- <leader>h* harpoon, <leader>p* project manager — xem chi tiết theo từng section ### bên dưới
if vim.g.vscode == nil then return end

local vscode = require 'vscode'
local function act(cmd)
  return function() vscode.action(cmd) end
end

-- Shorthand để map VSCode action theo mode:
--   n  → normal only
--   v  → visual only
--   nv → normal + visual
--   nx → normal + visual block (dùng cho operator-pending như gra)
local function n(key, cmd, desc)
  vim.keymap.set('n', key, act(cmd), {
    desc = desc,
  })
end
local function v(key, cmd, desc)
  vim.keymap.set('v', key, act(cmd), {
    desc = desc,
  })
end
local function nv(key, cmd, desc)
  vim.keymap.set({ 'n', 'v' }, key, act(cmd), {
    desc = desc,
  })
end
local function nx(key, cmd, desc)
  vim.keymap.set({ 'n', 'x' }, key, act(cmd), {
    desc = desc,
  })
end

-- ### JUMP
-- <leader>j → flash.nvim (custom/plugins/editor/flash.lua, chạy được cả terminal + VSCode)
-- Jumpy extension đã bỏ: conflict với vscode-neovim do hook 'type' command

-- ### FILE & SEARCH
-- Mở file nhanh (Quick Open, giống Ctrl+P mặc định của VSCode)
n('<C-p>', 'workbench.action.quickOpen', 'Quick Open file')
-- Tìm kiếm trong file hiện tại
n('<C-f>', 'actions.find', 'Tìm trong file hiện tại')
-- Tìm kiếm trong tất cả file của project
n('<C-S-f>', 'workbench.action.findInFiles', 'Tìm trong tất cả file')
-- Alias Telescope-style: mở file nhanh
n('<leader>sf', 'workbench.action.quickOpen', '[S]earch [F]iles')
-- Alias Telescope-style: tìm trong tất cả file
n('<leader>sg', 'workbench.action.findInFiles', '[S]earch by [G]rep')
-- n('<leader><leader>', 'workbench.action.showAllEditors', 'Tìm editor đang mở')
-- Fuzzy search trong file hiện tại (normal mode)
n('<leader>/', 'fuzzySearch.activeTextEditor', 'Fuzzy search trong file')
-- Fuzzy search với selection hiện tại làm query (visual mode)
v('<leader>/', 'fuzzySearch.activeTextEditorWithCurrentSelection', 'Fuzzy search selection')

-- MOVE
-- Thu nhỏ view/panel hiện tại
n('<leader><Left>', 'workbench.action.decreaseViewSize', 'Decrease View Size')
-- Phóng to view/panel hiện tại
n('<leader><Right>', 'workbench.action.increaseViewSize', 'Increase View Size')

-- ### TAB / INDENT
-- Tăng indent dòng/selection (alias phím Tab trong normal mode)
n('<tab>', 'editor.action.indentLines', 'Indent lines')
-- Giảm indent dòng/selection
n('<S-tab>', 'editor.action.outdentLines', 'Outdent lines')

-- Find It Faster (yêu cầu: fzf + rg + bat trên PATH)
-- Tìm file bằng fzf (nhanh hơn Quick Open, đặc biệt trên project lớn)
n('<leader>ff', 'find-it-faster.findFiles', '[F]ind [F]iles (fzf)')
-- Tìm file bằng fzf kết hợp lọc theo filetype
n('<leader>fF', 'find-it-faster.findFilesWithType', '[F]ind Files + filetype')
-- Grep trong nội dung file bằng fzf + ripgrep
n('<leader>fs', 'find-it-faster.findWithinFiles', '[F]ind within files')
-- Grep trong file kết hợp lọc theo filetype
n('<leader>fS', 'find-it-faster.findWithinFilesWithType', '[F]ind within files + type')
-- Tìm và thay thế trong tất cả file
n('<leader>fr', 'workbench.action.replaceInFiles', '[F]ind & [R]eplace in files')

-- ### LSP / CODE ACTIONS — g-prefix
-- Nhảy đến definition của symbol dưới cursor
n('gd', 'editor.action.revealDefinition', 'Goto definition')
-- Xem definition ngay tại chỗ trong popup (không rời file hiện tại)
n('gp', 'editor.action.peekDefinition', 'Peek definition')
-- Nhảy đến declaration (khác definition: declaration thường là prototype/header)
n('gD', 'editor.action.revealDeclaration', 'Goto declaration')
-- Xem tất cả references của symbol
n('gr', 'editor.action.goToReferences', 'Goto references')
-- Mở References panel để xem và navigate references
n('gR', 'references-view.find', 'References panel')
-- Nhảy đến implementation của interface/abstract (hữu ích khi làm việc với OOP)
n('gi', 'editor.action.goToImplementation', 'Goto implementation')
-- Xem type definition trong popup (kiểu của biến, không nhảy sang file)
n('gt', 'editor.action.peekTypeDefinition', 'Peek type definition')
-- Xem tất cả symbols trong file hiện tại (document outline)
n('gs', 'workbench.action.gotoSymbol', 'Document symbols')
-- Tìm symbol trong toàn workspace
n('gS', 'workbench.action.showAllSymbols', 'Workspace symbols')
-- Hiển thị hover docs / type info cho symbol dưới cursor
n('gk', 'editor.action.showHover', 'Hover docs')
-- Fuzzy search trong file hiện tại (g-prefix alias)
n('gf', 'fuzzySearch.activeTextEditor', 'Fuzzy search')

-- gr-prefix (kickstart-style aliases — giống keymaps LSP ở terminal)
-- Goto references (alias chuẩn kickstart)
n('grr', 'editor.action.goToReferences', '[G]oto [R]eferences')
-- Goto definition (alias chuẩn kickstart)
n('grd', 'editor.action.revealDefinition', '[G]oto [D]efinition')
-- Goto implementation (alias chuẩn kickstart)
n('gri', 'editor.action.goToImplementation', '[G]oto [I]mplementation')
-- Goto type definition (alias chuẩn kickstart)
n('grt', 'editor.action.goToTypeDefinition', '[G]oto [T]ype Definition')
-- Rename symbol (alias chuẩn kickstart)
n('grn', 'editor.action.rename', 'Rename')
-- Goto declaration (alias chuẩn kickstart)
n('grD', 'editor.action.revealDeclaration', '[G]oto [D]eclaration')
-- Code action / Quick fix (normal + visual block)
nx('gra', 'editor.action.quickFix', 'Code action')

-- ### FORMAT & DIAGNOSTICS
-- Format document (normal) hoặc selection (visual)
nv('<leader>f', 'editor.action.formatDocument', 'Format document')
-- Mở Problems panel để xem tất cả lỗi/warning trong project
n('<leader>q', 'workbench.actions.view.problems', 'Mở Problems panel')
-- Bật/tắt inlay hints (type annotations inline trong code)
n('<leader>th', 'editor.action.inlayHints.toggle', 'Toggle Inlay Hints')
-- Bật/tắt Error Lens (hiển thị lỗi/warning inline trên dòng code)
n('<leader>te', 'errorLens.toggle', 'Toggle Error Lens')

-- ### RENAME / REFACTOR
-- Rename symbol tại cursor (prefix khác với grn để tránh nhầm)
n('<leader>r', 'editor.action.rename', 'Rename symbol')
-- Mở refactor menu cho selection hiện tại (extract function, variable...)
v('<leader>;', 'editor.action.refactor', 'Refactor')
-- Toggle block comment cho selection
v('<leader>c', 'editor.action.blockComment', 'Block comment')

-- ### BUFFER / EDITOR
-- Đóng editor/tab hiện tại
n('<leader>bq', 'workbench.action.closeActiveEditor', '[B]uffer đóng')
-- Tạo file mới chưa đặt tên (untitled)
n('<leader>bn', 'workbench.action.files.newUntitledFile', '[B]uffer mới')
-- Chọn tất cả nội dung file (để copy; dùng tiếp với Ctrl+C)
n('<leader>by', 'editor.action.selectAll', '[B]uffer [Y]ank (select all → copy)')
-- Paste đè toàn bộ nội dung file bằng clipboard (ggVGp)
vim.keymap.set('n', '<leader>bp', 'ggVGp', { desc = '[B]uffer [P]aste (replace all)', silent = true })
-- NOTE: <C-m> = <CR> nên không dùng, dễ bị conflict với Enter
-- Dùng <leader>sl để đổi language mode thay thế
-- Đổi ngôn ngữ/syntax highlighting của file hiện tại
n('<leader>sl', 'workbench.action.editor.changeLanguageMode', 'Đổi [L]anguage mode')

-- ### SIDEBAR & UI
-- Bật/tắt sidebar (explorer, search, source control...)
n('<leader>e', 'workbench.action.toggleSidebarVisibility', 'Mở/đóng sidebar')
-- Mở panel Explorer (file tree)
n('<leader>ee', 'workbench.view.explorer', 'Explorer panel')
-- Mở panel Search
n('<leader>es', 'workbench.view.search', 'Search panel')
-- Mở Command Palette để chạy bất kỳ VSCode command nào
n('<leader>>', 'workbench.action.showCommands', 'Command palette')

-- ### PANE / WINDOW FOCUS
-- Focus pane/editor group bên trái
n('<C-h>', 'workbench.action.focusLeftGroup', 'Focus pane trái')
-- Focus pane/editor group bên phải
n('<C-l>', 'workbench.action.focusRightGroup', 'Focus pane phải')
-- Focus pane/editor group bên trái (alias với leader prefix)
n('<leader>wh', 'workbench.action.focusLeftGroup', '[W]indow trái')
-- Focus pane/editor group bên phải
n('<leader>wl', 'workbench.action.focusRightGroup', '[W]indow phải')
-- Focus pane/editor group bên trên
n('<leader>wk', 'workbench.action.focusAboveGroup', '[W]indow trên')
-- Focus pane/editor group bên dưới
n('<leader>wj', 'workbench.action.focusBelowGroup', '[W]indow dưới')
-- Dời dòng hiện tại xuống (C-j/k ở VSCode dùng để move lines, khác terminal)
n('<C-j>', 'editor.action.moveLinesDownAction', 'Dời dòng xuống')
-- Dời dòng hiện tại lên
n('<C-k>', 'editor.action.moveLinesUpAction', 'Dời dòng lên')

-- ### TERMINAL
-- Focus vào terminal panel (không tạo mới nếu đã có)
n('<leader>tf', 'workbench.action.terminal.focus', '[T]erminal focus')
-- Tạo terminal mới
n('<leader>tn', 'workbench.action.terminal.new', '[T]erminal mới')
-- Đóng terminal hiện tại
n('<leader>tk', 'workbench.action.terminal.killTerminalAfterUse', '[T]erminal kill')

-- ### GIT
-- Xem diff của file hiện tại so với index
n('<leader>gd', 'git.viewChanges', '[G]it diff')
-- Stage tất cả thay đổi (git add -A)
n('<leader>ga', 'git.stageAll', '[G]it add all')
-- Mở commit dialog để nhập message và commit
n('<leader>gc', 'git.commit', '[G]it commit')
-- Push branch hiện tại lên remote (dùng multiCommand để tránh popup xác nhận)
n('<leader>gps', 'multiCommand.runGitPush', '[G]it push (multiCommand)')
-- Pull từ remote về branch hiện tại
n('<leader>gpl', 'multiCommand.runGitPull', '[G]it pull (multiCommand)')
-- Checkout branch hoặc commit
n('<leader>gk', 'git.checkout', '[G]it checkout')
-- Tạo branch mới và checkout
n('<leader>gcb', 'git.branch', '[G]it checkout -b (new branch)')
-- Unstage file hiện tại (bỏ khỏi staging area)
n('<leader>gu', 'git.unstage', '[G]it unstage')
-- Undo commit cuối (giữ nguyên thay đổi, chỉ bỏ commit)
n('<leader>guc', 'git.undoCommit', '[G]it undo commit')
-- Xem changes của file hiện tại trong diff view
n('<leader>goc', 'git.viewChanges', '[G]it open changes')
-- Xem staged changes trong diff view
n('<leader>gos', 'git.viewStagedChanges', '[G]it open staged')
-- Mở file hiện tại trên remote (GitHub/GitLab) trong browser
n('<leader>gob', 'gitlens.openFileInRemote', '[G]it open in [R]emote (GitLens)')
-- Xem lịch sử commit của file hiện tại (GitLens)
n('<leader>gfh', 'gitlens.showQuickFileHistory', '[G]it [F]ile [H]istory')
-- Xem git log đẹp bằng multiCommand
n('<leader>gl', 'multiCommand.runGitLog', '[G]it [L]og')
-- Xem git history tương tác (GitLens)
n('<leader>gh', 'gitlens.gitCommand.history', '[G]it [H]istory (GitLens)')
-- Tạo Pull Request từ branch hiện tại lên remote
n('<leader>gm', 'gitlens.createPullRequestOnRemote', '[G]it [M]ake PR')
-- Cherry pick commit được chọn vào branch hiện tại
n('<leader>gcp', 'git.cherryPick', '[G]it cherry pick')
-- Abort cherry pick đang tiến hành
n('<leader>gca', 'git.cherryPickAbort', '[G]it cherry pick abort')
-- Xóa branch local
n('<leader>gdb', 'git.deleteBranch', '[G]it delete branch')
-- Xóa branch trên remote
n('<leader>gdr', 'git.deleteRemoteBranch', '[G]it delete remote branch')
-- Discard tất cả thay đổi của file hiện tại (git checkout -- <file>)
n('<leader>gDc', 'git.clean', '[G]it discard (current file)')
-- Discard tất cả thay đổi trong working tree
n('<leader>gDa', 'git.cleanAll', '[G]it discard all')
-- Tạo tag mới tại commit hiện tại
n('<leader>gtc', 'git.createTag', '[G]it tag create')
-- Push tất cả tags lên remote
n('<leader>gtp', 'git.pushTags', '[G]it tag push')
-- Xóa tag được chọn
n('<leader>gtd', 'git.deleteTag', '[G]it tag delete')

-- ### BOOKMARKS (extension: alefragnani.Bookmarks)
-- Toggle bookmark tại dòng hiện tại (thêm/xóa)
n('<leader>mt', 'bookmarks.toggle', '[M]ark toggle')
-- Toggle bookmark có nhãn tùy chỉnh
n('<leader>me', 'bookmarks.toggleLabeled', '[M]ark edit label')
-- Nhảy đến bookmark tiếp theo trong file
n('<leader>mn', 'bookmarks.jumpToNext', '[M]ark next')
-- Nhảy đến bookmark trước đó trong file
n('<leader>mp', 'bookmarks.jumpToPrevious', '[M]ark prev')
-- Danh sách bookmarks trong file hiện tại
n('<leader>ml', 'bookmarks.list', '[M]ark list (file)')
-- Danh sách bookmarks trong tất cả file
n('<leader>mL', 'bookmarks.listFromAllFiles', '[M]ark list (all)')
-- Xóa tất cả bookmarks trong file hiện tại
n('<leader>mC', 'bookmarks.clear', '[M]ark clear')
-- Xóa tất cả bookmarks trong mọi file
n('<leader>mA', 'bookmarks.clearFromAllFiles', '[M]ark clear all files')

-- ### HARPOON (extension: tobias-z.vscode-harpoon)
-- Quick pick danh sách file Harpoon đang theo dõi
n('<leader>hp', 'vscode-harpoon.editorQuickPick', '[H]arpoon pick')
-- Thêm file hiện tại vào danh sách Harpoon
n('<leader>ha', 'vscode-harpoon.addEditor', '[H]arpoon add')
-- Mở editor để chỉnh sửa danh sách Harpoon
n('<leader>he', 'vscode-harpoon.editEditors', '[H]arpoon edit list')

-- ### PROJECT MANAGER (extension: alefragnani.project-manager)
-- Danh sách project (mở trong cửa sổ mới)
n('<leader>pl', 'projectManager.listProjectsNewWindow', '[P]roject list (new window)')
-- Danh sách project (mở trong cửa sổ hiện tại)
n('<leader>pL', 'projectManager.listProjects', '[P]roject list')
-- Chỉnh sửa file cấu hình danh sách project
n('<leader>pe', 'projectManager.editProjects', '[P]roject edit')
-- Refresh danh sách project (scan lại thư mục)
n('<leader>pr', 'projectManager.refreshProjects', '[P]roject refresh')

-- ### DEVELOPER
-- Reload toàn bộ cửa sổ VSCode (hữu ích khi extension hoặc settings thay đổi)
n('<leader>Dr', 'workbench.action.reloadWindow', '[D]ev reload window')

-- ### SETTINGS
-- Mở Settings UI (tìm kiếm setting bằng giao diện đồ họa)
n('<leader>su', 'workbench.action.openSettings', '[S]ettings UI')
-- Mở Settings JSON (chỉnh trực tiếp file settings.json)
n('<leader>sj', 'workbench.action.openSettingsJson', '[S]ettings JSON')
-- Mở Keybindings UI (giao diện quản lý keybindings)
n('<leader>sku', 'workbench.action.openGlobalKeybindings', '[S]ettings [K]eybindings UI')
-- Mở Keybindings JSON (chỉnh trực tiếp file keybindings.json)
n('<leader>skj', 'workbench.action.openGlobalKeybindingsFile', '[S]ettings [K]eybindings JSON')
-- Chọn color theme
n('<leader>st', 'workbench.action.selectTheme', '[S]ettings color [T]heme')
-- Chọn icon theme
n('<leader>si', 'workbench.action.selectIconTheme', '[S]ettings [I]con theme')

-- ### SYSTEM SHORTCUTS
-- C-c/v/x/z/n/g KHÔNG map qua Neovim — bị loại khỏi ctrlKeysForNormalMode trong settings.json
-- → VSCode xử lý native: Ctrl+C=copy, Ctrl+V=paste, Ctrl+X=cut, Ctrl+Z=undo (Windows default)
-- → C-v visual-block: dùng <C-q> thay thế
-- Nhảy đến số dòng cụ thể (Go to Line dialog)
n('<C-g>', 'workbench.action.gotoLine', 'Go to line')

-- ### KEYS CÒN TRỐNG (chưa dùng ở đâu trong vscode.lua/init.lua, để dành cho sau)
-- <leader> không đụng lệnh Vim gốc nào (Space bare chỉ là "di chuyển phải"),
-- nên toàn bộ danh sách dưới đây an toàn 100%, không cần lo conflict.
--
-- <leader> + chữ thường còn trống: a c d i j k l o u x z
-- <leader> + chữ HOA còn trống (trừ D, S đã dùng): A B C E F G H I J K L M N O P Q R T U V W X Y Z
-- <leader> + ký hiệu còn trống: . , ' ` - _ = + [ ] { } | \ ~ ? ! @ # $ % ^ & * ( )
-- <leader> + số (0-9): còn trống hết
--
-- Lưu ý: các phím KHÔNG có <leader> (bare key, vd 's', 'Q'...) hầu hết đã bị
-- Vim gốc chiếm dụng (:help index.txt) — chỉ nên map bare key khi chắc chắn
-- không cần lệnh gốc đó (xem lại vụ 'mt' đụng lệnh mark `m` ở trên).
