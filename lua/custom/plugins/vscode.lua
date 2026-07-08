-- VSCode keymaps (chỉ chạy khi vscode-neovim active)
-- Map các VSCode command vào Neovim keymaps để dùng workflow quen thuộc
-- Bao gồm: LSP, git, terminal, sidebar, bookmarks, harpoon, project manager
-- Extension cần: vscode-neovim, Find It Faster, Fuzzy Search, Bookmarks, Harpoon, Project Manager
if vim.g.vscode == nil then
  return
end

local vscode = require 'vscode'
local function act(cmd)
  return function()
    vscode.action(cmd)
  end
end

-- Shorthand để map VSCode action theo mode:
--   n  → normal only
--   v  → visual only
--   nv → normal + visual
--   nx → normal + visual block (dùng cho operator-pending như gra)
local function n(key, cmd, desc)
  vim.keymap.set('n', key, act(cmd), {
    desc = desc
  })
end
local function v(key, cmd, desc)
  vim.keymap.set('v', key, act(cmd), {
    desc = desc
  })
end
local function nv(key, cmd, desc)
  vim.keymap.set({'n', 'v'}, key, act(cmd), {
    desc = desc
  })
end
local function nx(key, cmd, desc)
  vim.keymap.set({'n', 'x'}, key, act(cmd), {
    desc = desc
  })
end

-- ### JUMP (wmaurer.vscode-jumpy — thay thế flash.nvim trong VSCode)
-- <leader>j → word mode: hiện label 2 ký tự trên từng từ, gõ 2 ký tự để nhảy
n('<leader>j', 'extension.jumpy-word', 'Jump word (jumpy)')
-- n('S', 'extension.jumpy-line', 'Jump line (jumpy)')

-- ### FILE & SEARCH
n('<C-p>', 'workbench.action.quickOpen', 'Quick Open file')
n('<C-f>', 'actions.find', 'Tìm trong file hiện tại')
n('<C-S-f>', 'workbench.action.findInFiles', 'Tìm trong tất cả file')
n('<leader>sf', 'workbench.action.quickOpen', '[S]earch [F]iles')
n('<leader>sg', 'workbench.action.findInFiles', '[S]earch by [G]rep')
-- n('<leader><leader>', 'workbench.action.showAllEditors', 'Tìm editor đang mở')
n('<leader>/', 'fuzzySearch.activeTextEditor', 'Fuzzy search trong file')
v('<leader>/', 'fuzzySearch.activeTextEditorWithCurrentSelection', 'Fuzzy search selection')

-- MOVE
n('<leader><Left>', 'workbench.action.decreaseViewSize', 'Decrease View Size')
n('<leader><Right>', 'workbench.action.increaseViewSize', 'Increase View Size')

-- ### TAB / INDENT
n('<tab>', 'editor.action.indentLines', 'Indent lines')
n('<S-tab>', 'editor.action.outdentLines', 'Outdent lines')

-- Find It Faster (yêu cầu: fzf + rg + bat trên PATH)
n('<leader>ff', 'find-it-faster.findFiles', '[F]ind [F]iles (fzf)')
n('<leader>fF', 'find-it-faster.findFilesWithType', '[F]ind Files + filetype')
n('<leader>fs', 'find-it-faster.findWithinFiles', '[F]ind within files')
n('<leader>fS', 'find-it-faster.findWithinFilesWithType', '[F]ind within files + type')
n('<leader>fr', 'workbench.action.replaceInFiles', '[F]ind & [R]eplace in files')

-- ### LSP / CODE ACTIONS — g-prefix
n('gd', 'editor.action.revealDefinition', 'Goto definition')
n('gp', 'editor.action.peekDefinition', 'Peek definition')
n('gD', 'editor.action.revealDeclaration', 'Goto declaration')
n('gr', 'editor.action.goToReferences', 'Goto references')
n('gR', 'references-view.find', 'References panel')
n('gi', 'editor.action.goToImplementation', 'Goto implementation')
n('gt', 'editor.action.peekTypeDefinition', 'Peek type definition')
n('gs', 'workbench.action.gotoSymbol', 'Document symbols')
n('gS', 'workbench.action.showAllSymbols', 'Workspace symbols')
n('gk', 'editor.action.showHover', 'Hover docs')
n('gf', 'fuzzySearch.activeTextEditor', 'Fuzzy search')

-- gr-prefix (kickstart-style aliases)
n('grr', 'editor.action.goToReferences', '[G]oto [R]eferences')
n('grd', 'editor.action.revealDefinition', '[G]oto [D]efinition')
n('gri', 'editor.action.goToImplementation', '[G]oto [I]mplementation')
n('grt', 'editor.action.goToTypeDefinition', '[G]oto [T]ype Definition')
n('grn', 'editor.action.rename', 'Rename')
n('grD', 'editor.action.revealDeclaration', '[G]oto [D]eclaration')
nx('gra', 'editor.action.quickFix', 'Code action')

-- ### FORMAT & DIAGNOSTICS
nv('<leader>f', 'editor.action.formatDocument', 'Format document')
n('<leader>q', 'workbench.actions.view.problems', 'Mở Problems panel')
n('<leader>th', 'editor.action.inlayHints.toggle', 'Toggle Inlay Hints')
n('<leader>te', 'errorLens.toggle', 'Toggle Error Lens')

-- ### RENAME / REFACTOR
n('<leader>r', 'editor.action.rename', 'Rename symbol')
v('<leader>;', 'editor.action.refactor', 'Refactor')
v('<leader>c', 'editor.action.blockComment', 'Block comment')

-- ### BUFFER / EDITOR
n('<leader>bq', 'workbench.action.closeActiveEditor', '[B]uffer đóng')
n('<leader>bn', 'workbench.action.files.newUntitledFile', '[B]uffer mới')
n('<leader>by', 'editor.action.selectAll', '[B]uffer [Y]ank (select all → copy)')
vim.keymap.set('n', '<leader>bp', 'ggVGp', { desc = '[B]uffer [P]aste (replace all)', silent = true })
-- NOTE: <C-m> = <CR> nên không dùng, dễ bị conflict với Enter
-- Dùng <leader>sl để đổi language mode thay thế
n('<leader>sl', 'workbench.action.editor.changeLanguageMode', 'Đổi [L]anguage mode')

-- ### SIDEBAR & UI
n('<leader>e', 'workbench.action.toggleSidebarVisibility', 'Mở/đóng sidebar')
n('<leader>ee', 'workbench.view.explorer', 'Explorer panel')
n('<leader>es', 'workbench.view.search', 'Search panel')
n('<leader>>', 'workbench.action.showCommands', 'Command palette')

-- ### PANE / WINDOW FOCUS
n('<C-h>', 'workbench.action.focusLeftGroup', 'Focus pane trái')
n('<C-l>', 'workbench.action.focusRightGroup', 'Focus pane phải')
n('<leader>wh', 'workbench.action.focusLeftGroup', '[W]indow trái')
n('<leader>wl', 'workbench.action.focusRightGroup', '[W]indow phải')
n('<leader>wk', 'workbench.action.focusAboveGroup', '[W]indow trên')
n('<leader>wj', 'workbench.action.focusBelowGroup', '[W]indow dưới')
n('<C-j>', 'editor.action.moveLinesDownAction', 'Dời dòng xuống')
n('<C-k>', 'editor.action.moveLinesUpAction', 'Dời dòng lên')

-- ### TERMINAL
n('<leader>tf', 'workbench.action.terminal.focus', '[T]erminal focus')
n('<leader>tn', 'workbench.action.terminal.new', '[T]erminal mới')
n('<leader>tk', 'workbench.action.terminal.killTerminalAfterUse', '[T]erminal kill')

-- ### GIT
n('<leader>gd', 'git.viewChanges', '[G]it diff')
n('<leader>ga', 'git.stageAll', '[G]it add all')
n('<leader>gc', 'git.commit', '[G]it commit')
n('<leader>gps', 'multiCommand.runGitPush', '[G]it push (multiCommand)')
n('<leader>gpl', 'multiCommand.runGitPull', '[G]it pull (multiCommand)')
n('<leader>gk', 'git.checkout', '[G]it checkout')
n('<leader>gcb', 'git.branch', '[G]it checkout -b (new branch)')
n('<leader>gu', 'git.unstage', '[G]it unstage')
n('<leader>guc', 'git.undoCommit', '[G]it undo commit')
n('<leader>goc', 'git.viewChanges', '[G]it open changes')
n('<leader>gos', 'git.viewStagedChanges', '[G]it open staged')
n('<leader>gob', 'gitlens.openFileInRemote', '[G]it open in [R]emote (GitLens)')
n('<leader>gfh', 'gitlens.showQuickFileHistory', '[G]it [F]ile [H]istory')
n('<leader>gl', 'multiCommand.runGitLog', '[G]it [L]og')
n('<leader>gh', 'gitlens.gitCommand.history', '[G]it [H]istory (GitLens)')
n('<leader>gm', 'gitlens.createPullRequestOnRemote', '[G]it [M]ake PR')
n('<leader>gcp', 'git.cherryPick', '[G]it cherry pick')
n('<leader>gca', 'git.cherryPickAbort', '[G]it cherry pick abort')
n('<leader>gdb', 'git.deleteBranch', '[G]it delete branch')
n('<leader>gdr', 'git.deleteRemoteBranch', '[G]it delete remote branch')
n('<leader>gDc', 'git.clean', '[G]it discard (current file)')
n('<leader>gDa', 'git.cleanAll', '[G]it discard all')
n('<leader>gtc', 'git.createTag', '[G]it tag create')
n('<leader>gtp', 'git.pushTags', '[G]it tag push')
n('<leader>gtd', 'git.deleteTag', '[G]it tag delete')

-- ### BOOKMARKS (extension: alefragnani.Bookmarks)
n('<leader>mt', 'bookmarks.toggle', '[M]ark toggle')
n('<leader>me', 'bookmarks.toggleLabeled', '[M]ark edit label')
n('<leader>mn', 'bookmarks.jumpToNext', '[M]ark next')
n('<leader>mp', 'bookmarks.jumpToPrevious', '[M]ark prev')
n('<leader>ml', 'bookmarks.list', '[M]ark list (file)')
n('<leader>mL', 'bookmarks.listFromAllFiles', '[M]ark list (all)')
n('<leader>mC', 'bookmarks.clear', '[M]ark clear')
n('<leader>mA', 'bookmarks.clearFromAllFiles', '[M]ark clear all files')

-- ### HARPOON (extension: tobias-z.vscode-harpoon)
n('<leader>hp', 'vscode-harpoon.editorQuickPick', '[H]arpoon pick')
n('<leader>ha', 'vscode-harpoon.addEditor', '[H]arpoon add')
n('<leader>he', 'vscode-harpoon.editEditors', '[H]arpoon edit list')

-- ### PROJECT MANAGER (extension: alefragnani.project-manager)
n('<leader>pl', 'projectManager.listProjectsNewWindow', '[P]roject list (new window)')
n('<leader>pL', 'projectManager.listProjects', '[P]roject list')
n('<leader>pe', 'projectManager.editProjects', '[P]roject edit')
n('<leader>pr', 'projectManager.refreshProjects', '[P]roject refresh')

-- ### DEVELOPER
n('<leader>Dr', 'workbench.action.reloadWindow', '[D]ev reload window')

-- ### SETTINGS
n('<leader>su', 'workbench.action.openSettings', '[S]ettings UI')
n('<leader>sj', 'workbench.action.openSettingsJson', '[S]ettings JSON')
n('<leader>sku', 'workbench.action.openGlobalKeybindings', '[S]ettings [K]eybindings UI')
n('<leader>skj', 'workbench.action.openGlobalKeybindingsFile', '[S]ettings [K]eybindings JSON')
n('<leader>st', 'workbench.action.selectTheme', '[S]ettings color [T]heme')
n('<leader>si', 'workbench.action.selectIconTheme', '[S]ettings [I]con theme')

-- ### SYSTEM SHORTCUTS
-- C-c/v/x/z/n/g KHÔNG map qua Neovim — bị loại khỏi ctrlKeysForNormalMode trong settings.json
-- → VSCode xử lý native: Ctrl+C=copy, Ctrl+V=paste, Ctrl+X=cut, Ctrl+Z=undo (Windows default)
-- → C-v visual-block: dùng <C-q> thay thế
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
