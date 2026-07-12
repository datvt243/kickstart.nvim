# Neovim Config — _david

Config Neovim cá nhân dựa trên [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), chạy được ở **hai môi trường**:

- **Terminal Neovim** — full plugin stack (LSP, Telescope, Treesitter, blink.cmp, flash.nvim...)
- **VSCode + vscode-neovim** — mini.ai + mini.surround + mini.move + flash.nvim + keymaps qua `vscode.action()`

## Yêu cầu

- Neovim stable mới nhất
- `git`, `make`, `ripgrep`, `fd`
- [Nerd Font](https://www.nerdfonts.com/) (đặt `vim.g.have_nerd_font = true` trong `init.lua`)
- Node.js (cho một số LSP server)
- Go toolchain (cho `gopls`, nếu code Go)

## Cài đặt

```bash
git clone https://github.com/datvt243/kickstart.nvim.git ~/.config/nvim
nvim
```

`vim.pack` sẽ tự cài toàn bộ plugin khi khởi động lần đầu.

## Plugin manager

Dùng **`vim.pack`** — plugin manager tích hợp sẵn trong Neovim (không dùng lazy.nvim):

```bash
:PackUpdate          # cập nhật plugin
:lua vim.pack.update(nil, { offline = true })   # xem trạng thái
:ReloadConfig         # reload toàn bộ config, không cần thoát/vào lại
```

## Cấu trúc

```
init.lua                        — shared keymaps, vim.pack hooks, load plugins
lua/
  options.lua                    — vim.g/vim.o/vim.opt (leader keys, core options, swapfile, autosave); required by init.lua
  custom/plugins/               — plugin files (auto-loaded recursively by init.lua)
    init.lua                    — auto-loader: requires every .lua file in the tree (incl. subfolders)
    dashboard.lua                — dashboard-nvim: welcome screen (terminal)
    lsp.lua                     — nvim-lspconfig + Mason + fidget + lazydev (terminal)
    telescope.lua                — Telescope fuzzy finder (terminal)
    vscode.lua                  — VSCode keymaps via vscode.action() (VSCode only)
    editor/                     — editing behavior / motion plugins, always auto-loaded (no opt-in toggle)
      flash.lua                 — flash.nvim: jump nhanh bằng s/S/<leader>j (both)
      text-objects.lua          — mini.surround + mini.move + guess-indent (both)
      neoscroll.lua              — neoscroll.nvim: smooth scrolling (terminal)
      scrollbar.lua              — nvim-scrollbar: git change/diagnostics on the scrollbar (terminal)
      indent_line.lua           — [ENABLED] indent guides (terminal)
      whichkey.lua              — which-key.nvim: keymap hints when pressing leader (terminal)
      trouble.lua               — trouble.nvim: diagnostics/quickfix/loclist/LSP refs list, <leader>x* (terminal)
      goto-preview.lua          — goto-preview.nvim: peek definition/type/impl/decl/refs editable,
                                    gp/gpt/gpi/gpD/gpr/gP/Esc (terminal)
      todo-comments.lua         — todo-comments.nvim: highlight TODO/FIXME/NOTE/HACK/WARN (terminal)
    coding/                     — language/code-writing helper plugins, always auto-loaded (no opt-in toggle)
      ts-comments.lua           — ts-comments.nvim: accurate comment string via treesitter (terminal)
      mini-ai.lua               — mini.ai: text objects mở rộng (both)
      autopairs.lua             — nvim-autopairs: auto-close brackets (terminal)
      blink-cmp.lua             — blink.cmp: autocomplete engine, marker `### BLINK.CMP KEYMAPS` (terminal)
      luasnip.lua               — LuaSnip: snippet engine, nguồn snippet cho blink.cmp (terminal)
      lazydev.lua               — lazydev.nvim: lua_ls type cho Neovim config/plugin (terminal)
    colorscheme/                — colorscheme + theme-adjacent UI plugins, always auto-loaded (no opt-in toggle)
      tokyonight.lua            — [INACTIVE] tokyonight.nvim: colorscheme, full setup options (terminal)
      catppuccin.lua            — [ACTIVE] catppuccin.nvim: colorscheme, full setup options (terminal)
    formatting/                 — code-formatting plugins, always auto-loaded (no opt-in toggle)
      conform.lua               — conform.nvim: formatter, <leader>qf/qF/qc (terminal)
    ui/                         — small standalone UI plugins, always auto-loaded (no opt-in toggle)
      icons.lua                 — mini.icons: icon theo filetype, mock_nvim_web_devicons() — LOAD TRƯỚC (xem custom/plugins/init.lua)
      lualine.lua               — lualine.nvim: statusline, theme = 'auto' theo colorscheme active (terminal)
      noice.lua                 — noice.nvim: floating cmdline + notifications (terminal)
      bufferline.lua            — [DISABLED via `local enabled = false` in file] tab bar showing open buffers, themable (terminal)
      render-markdown.lua       — render-markdown.nvim: render markdown ngay trong buffer khi edit .md (terminal)
    treesitter/                 — syntax parsing, always auto-loaded (no opt-in toggle)
      treesitter.lua            — nvim-treesitter (terminal)
      autotag.lua               — nvim-ts-autotag: auto-close/rename cặp thẻ HTML/JSX/TSX (terminal)
    tools/                      — external tool integrations, always auto-loaded (no opt-in toggle)
      claudecode.lua            — Claude Code integration (terminal)
      project.lua               — project.nvim: auto-detect root + Telescope picker; tự đóng buffer
                                    chưa sửa khi đổi project (DirChanged) (terminal)
      terminal.lua              — toggleterm.nvim: small terminal at the bottom (terminal)
      codesnap.lua              — codesnap.nvim: capture code as an image (terminal)
      import-cost.lua           — vim-import-cost: shows KB per JS/TS import (terminal)
  kickstart/plugins/            — optional plugins (uncomment in Section 10 to enable)
    debug.lua                   — DAP debugger
    gitsigns.lua                — [ENABLED] full git keymaps
    lint.lua                    — linter
    neo-tree.lua                — [ENABLED] advanced file explorer: \, <leader>e, <leader>ee
  health.lua                    — config health check
```

> Chi tiết đầy đủ từng file/plugin: xem `CLAUDE.md`.

## Keymaps nổi bật

> Xem đầy đủ tại 
 - [`keymaps-terminal.md`](keymaps-terminal.md) (Terminal Neovim) 
 - [`keymaps-vscode.md`](keymaps-vscode.md) (VSCode)

## VSCode — Extensions cần cài

| Extension | ID |
|---|---|
| vscode-neovim | `asvetliakov.vscode-neovim` |
| Which Key | `vspacecode.whichkey` |
| Find It Faster | `TomiTurtinen.find-it-faster` |
| Fuzzy Search | `jacobdufault.fuzzy-search` |
| Bookmarks | `alefragnani.Bookmarks` |
| Harpoon | `tobias-z.vscode-harpoon` |
| Project Manager | `alefragnani.project-manager` |

> Disable `vscodevim.vim` nếu đã cài: `code --disable-extension vscodevim.vim`

> **Jump:** Dùng `flash.nvim` (Neovim plugin) thay Jumpy — `<leader>j`. Jumpy bị bỏ vì conflict với vscode-neovim do hook `type` command.

## Thêm LSP server

Mở `lua/custom/plugins/lsp.lua`, thêm vào `local servers = { ... }`:

```lua
pyright = {},
```

Mason sẽ tự cài khi khởi động lại.

## Format Lua

```bash
~/.local/share/nvim/mason/bin/stylua init.lua lua/**/*.lua
```
