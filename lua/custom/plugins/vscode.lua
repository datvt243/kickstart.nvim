if vim.g.vscode == nil then return end

local vscode = require 'vscode'
local function act(cmd) return function() vscode.action(cmd) end end

-- ### FILE & SEARCH
vim.keymap.set('n', '<C-p>', act 'workbench.action.quickOpen', { desc = 'Quick Open file' })
vim.keymap.set('n', '<C-f>', act 'actions.find', { desc = 'Tìm trong file hiện tại' })
vim.keymap.set('n', '<leader>sf', act 'workbench.action.quickOpen', { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sg', act 'workbench.action.findInFiles', { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader><leader>', act 'workbench.action.showAllEditors', { desc = 'Tìm editor đang mở' })
vim.keymap.set('n', '<leader>/', act 'fuzzySearch.activeTextEditor', { desc = 'Fuzzy search trong file' })
vim.keymap.set('v', '<leader>/', act 'fuzzySearch.activeTextEditorWithCurrentSelection', { desc = 'Fuzzy search selection' })

-- Find It Faster (yêu cầu: fzf + rg + bat trên PATH)
vim.keymap.set('n', '<leader>ff', act 'find-it-faster.findFiles', { desc = '[F]ind [F]iles (fzf)' })
vim.keymap.set('n', '<leader>fF', act 'find-it-faster.findFilesWithType', { desc = '[F]ind Files + filetype' })
vim.keymap.set('n', '<leader>fs', act 'find-it-faster.findWithinFiles', { desc = '[F]ind within files' })
vim.keymap.set('n', '<leader>fS', act 'find-it-faster.findWithinFilesWithType', { desc = '[F]ind within files + type' })

-- ### LSP / CODE ACTIONS
-- g-prefix (giống vscodevim cũ)
vim.keymap.set('n', 'gd', act 'editor.action.revealDefinition', { desc = 'Goto definition' })
vim.keymap.set('n', 'gp', act 'editor.action.peekDefinition', { desc = 'Peek definition' })
vim.keymap.set('n', 'gD', act 'editor.action.revealDeclaration', { desc = 'Goto declaration' })
vim.keymap.set('n', 'gr', act 'editor.action.goToReferences', { desc = 'Goto references' })
vim.keymap.set('n', 'gR', act 'references-view.find', { desc = 'References panel' })
vim.keymap.set('n', 'gi', act 'editor.action.goToImplementation', { desc = 'Goto implementation' })
vim.keymap.set('n', 'gt', act 'editor.action.peekTypeDefinition', { desc = 'Peek type definition' })
vim.keymap.set('n', 'gs', act 'workbench.action.gotoSymbol', { desc = 'Document symbols' })
vim.keymap.set('n', 'gS', act 'workbench.action.showAllSymbols', { desc = 'Workspace symbols' })
vim.keymap.set('n', 'gk', act 'editor.action.showHover', { desc = 'Hover docs' })
vim.keymap.set('n', 'gf', act 'fuzzySearch.activeTextEditor', { desc = 'Fuzzy search' })

-- gr-prefix (kickstart-style aliases)
vim.keymap.set('n', 'grr', act 'editor.action.goToReferences', { desc = '[G]oto [R]eferences' })
vim.keymap.set('n', 'grd', act 'editor.action.revealDefinition', { desc = '[G]oto [D]efinition' })
vim.keymap.set('n', 'gri', act 'editor.action.goToImplementation', { desc = '[G]oto [I]mplementation' })
vim.keymap.set('n', 'grt', act 'editor.action.goToTypeDefinition', { desc = '[G]oto [T]ype Definition' })
vim.keymap.set('n', 'grn', act 'editor.action.rename', { desc = 'Rename' })
vim.keymap.set({ 'n', 'x' }, 'gra', act 'editor.action.quickFix', { desc = 'Code action' })
vim.keymap.set('n', 'grD', act 'editor.action.revealDeclaration', { desc = '[G]oto [D]eclaration' })

-- ### FORMAT & DIAGNOSTICS
vim.keymap.set({ 'n', 'v' }, '<leader>f', act 'editor.action.formatDocument', { desc = 'Format document' })
vim.keymap.set('n', '<leader>q', act 'workbench.actions.view.problems', { desc = 'Mở Problems panel' })
vim.keymap.set('n', '<leader>th', act 'editor.action.inlayHints.toggle', { desc = 'Toggle Inlay Hints' })

-- ### RENAME / REFACTOR
vim.keymap.set('n', '<leader>r', act 'editor.action.rename', { desc = 'Rename symbol' })
vim.keymap.set('v', '<leader>;', act 'editor.action.refactor', { desc = 'Refactor' })

-- ### BUFFER / EDITOR
vim.keymap.set('n', '<leader>bq', act 'workbench.action.closeActiveEditor', { desc = '[B]uffer đóng' })
vim.keymap.set('n', '<leader>bn', act 'workbench.action.files.newUntitledFile', { desc = '[B]uffer mới' })
vim.keymap.set('n', '<C-m>', act 'workbench.action.editor.changeLanguageMode', { desc = 'Đổi language mode' })

-- ### SIDEBAR & UI
vim.keymap.set('n', '<leader>e', act 'workbench.action.toggleSidebarVisibility', { desc = 'Mở/đóng sidebar' })
vim.keymap.set('n', '<leader>>', act 'workbench.action.showCommands', { desc = 'Command palette' })

-- ### PANE / WINDOW FOCUS
-- C-j/C-k ở normal mode → move lines (giống vscodevim cũ)
-- C-h/C-l → focus pane trái/phải
-- <leader>w{h,l,k,j} → focus pane theo hướng
vim.keymap.set('n', '<C-h>', act 'workbench.action.focusLeftGroup', { desc = 'Focus pane trái' })
vim.keymap.set('n', '<C-l>', act 'workbench.action.focusRightGroup', { desc = 'Focus pane phải' })
vim.keymap.set('n', '<leader>wh', act 'workbench.action.focusLeftGroup', { desc = '[W]indow trái' })
vim.keymap.set('n', '<leader>wl', act 'workbench.action.focusRightGroup', { desc = '[W]indow phải' })
vim.keymap.set('n', '<leader>wk', act 'workbench.action.focusAboveGroup', { desc = '[W]indow trên' })
vim.keymap.set('n', '<leader>wj', act 'workbench.action.focusBelowGroup', { desc = '[W]indow dưới' })
vim.keymap.set('n', '<C-j>', act 'editor.action.moveLinesDownAction', { desc = 'Dời dòng xuống' })
vim.keymap.set('n', '<C-k>', act 'editor.action.moveLinesUpAction', { desc = 'Dời dòng lên' })

-- ### TERMINAL
vim.keymap.set('n', '<leader>tf', act 'workbench.action.terminal.focus', { desc = '[T]erminal focus' })
vim.keymap.set('n', '<leader>tn', act 'workbench.action.terminal.new', { desc = '[T]erminal mới' })
vim.keymap.set('n', '<leader>tk', act 'workbench.action.terminal.killTerminalAfterUse', { desc = '[T]erminal kill' })

-- ### GIT
vim.keymap.set('n', '<leader>gd', act 'git.viewChanges', { desc = '[G]it diff' })
vim.keymap.set('n', '<leader>ga', act 'git.stageAll', { desc = '[G]it add all' })
vim.keymap.set('n', '<leader>gc', act 'git.commit', { desc = '[G]it commit' })
vim.keymap.set('n', '<leader>gp', act 'git.pushTo', { desc = '[G]it push' })
vim.keymap.set('n', '<leader>gP', act 'git.pullFrom', { desc = '[G]it pull' })
vim.keymap.set('n', '<leader>gk', act 'git.checkout', { desc = '[G]it checkout' })
vim.keymap.set('n', '<leader>gu', act 'git.unstage', { desc = '[G]it unstage' })
vim.keymap.set('n', '<leader>guc', act 'git.undoCommit', { desc = '[G]it undo commit' })
vim.keymap.set('n', '<leader>goc', act 'git.viewChanges', { desc = '[G]it open changes' })
vim.keymap.set('n', '<leader>gos', act 'git.viewStagedChanges', { desc = '[G]it open staged' })
vim.keymap.set('n', '<leader>gcp', act 'git.cherryPick', { desc = '[G]it cherry pick' })
vim.keymap.set('n', '<leader>gdb', act 'git.deleteBranch', { desc = '[G]it delete branch' })

-- ### BOOKMARKS (extension: alefragnani.Bookmarks)
vim.keymap.set('n', '<leader>mt', act 'bookmarks.toggle', { desc = '[M]ark toggle' })
vim.keymap.set('n', '<leader>me', act 'bookmarks.toggleLabeled', { desc = '[M]ark edit label' })
vim.keymap.set('n', '<leader>mn', act 'bookmarks.jumpToNext', { desc = '[M]ark next' })
vim.keymap.set('n', '<leader>mp', act 'bookmarks.jumpToPrevious', { desc = '[M]ark prev' })
vim.keymap.set('n', '<leader>ml', act 'bookmarks.list', { desc = '[M]ark list (file)' })
vim.keymap.set('n', '<leader>mL', act 'bookmarks.listFromAllFiles', { desc = '[M]ark list (all)' })
vim.keymap.set('n', '<leader>mC', act 'bookmarks.clear', { desc = '[M]ark clear' })

-- ### HARPOON (extension: tobias-z.vscode-harpoon)
vim.keymap.set('n', '<leader>hp', act 'vscode-harpoon.editorQuickPick', { desc = '[H]arpoon pick' })
vim.keymap.set('n', '<leader>ha', act 'vscode-harpoon.addEditor', { desc = '[H]arpoon add' })
vim.keymap.set('n', '<leader>he', act 'vscode-harpoon.editEditors', { desc = '[H]arpoon edit list' })

-- ### PROJECT MANAGER (extension: alefragnani.project-manager)
vim.keymap.set('n', '<leader>pl', act 'projectManager.listProjectsNewWindow', { desc = '[P]roject list (new window)' })
vim.keymap.set('n', '<leader>pL', act 'projectManager.listProjects', { desc = '[P]roject list' })
vim.keymap.set('n', '<leader>pe', act 'projectManager.editProjects', { desc = '[P]roject edit' })
vim.keymap.set('n', '<leader>pr', act 'projectManager.refreshProjects', { desc = '[P]roject refresh' })

-- ### SETTINGS
vim.keymap.set('n', '<leader>su', act 'workbench.action.openSettings', { desc = '[S]ettings UI' })
vim.keymap.set('n', '<leader>sj', act 'workbench.action.openSettingsJson', { desc = '[S]ettings JSON' })
