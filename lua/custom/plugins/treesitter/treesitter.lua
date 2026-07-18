-- nvim-treesitter: parse source code thành AST để highlight chính xác hơn regex (terminal only)
-- Tự động cài parser khi mở file lần đầu (FileType autocmd); cũng dùng cho indent thông minh theo ngôn ngữ
-- https://github.com/nvim-treesitter/nvim-treesitter

if vim.g.vscode ~= nil then return end

vim.pack.add { {
  src = gh 'nvim-treesitter/nvim-treesitter',
  version = 'main',
} }

-- Parser cần cho config này; parser khác tự cài khi mở file (FileType autocmd bên dưới)
local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }

-- Parser đã resolve được qua runtime (Neovim bundle sẵn, hoặc nvim-treesitter đã cài trước đó) thì
-- không cần cài lại. get_installed() của nvim-treesitter chỉ quét thư mục riêng của nó, không thấy
-- parser Neovim bundle ở lib/nvim/parser → nếu không lọc, mỗi startup sẽ cố compile lại cả nhóm này.
local function parser_available(lang) return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.so', false) > 0 end

-- nvim-treesitter (branch main) compile parser bằng `tree-sitter build`, cần cả CLI `tree-sitter`
-- lẫn 1 C compiler thật (cc/clang/gcc trên Unix, cl.exe/MSVC trên Windows). Thiếu bất kỳ cái nào thì
-- compile luôn fail và log lỗi mỗi lần startup/mở file (vd Windows không MSVC) → chỉ thử cài khi đủ.
local function can_compile()
  if vim.fn.executable 'tree-sitter' ~= 1 then return false end
  local ccs = vim.fn.has 'win32' == 1 and { 'cl' } or { 'cc', 'clang', 'gcc' }
  for _, cc in ipairs(ccs) do
    if vim.fn.executable(cc) == 1 then return true end
  end
  return false
end

-- Chỉ cài parser còn thiếu thật sự, và chỉ khi máy có toolchain compile được
if can_compile() then
  local missing = vim.tbl_filter(function(lang) return not parser_available(lang) end, parsers)
  if #missing > 0 then require('nvim-treesitter').install(missing) end
end

---@param buf integer
---@param language string
local function treesitter_try_attach(buf, language)
  if not vim.treesitter.language.add(language) then return end
  vim.treesitter.start(buf, language)

  -- Bỏ comment để bật treesitter-based folds:
  -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  -- vim.wo.foldmethod = 'expr'

  local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil
  if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
end

local available_parsers = require('nvim-treesitter').get_available()
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter-auto-install', {
    clear = true,
  }),
  callback = function(args)
    local buf, filetype = args.buf, args.match
    local language = vim.treesitter.language.get_lang(filetype)
    if not language then return end

    if parser_available(language) then
      -- Parser đã có sẵn (bundled/đã cài) → attach thẳng, không compile lại
      treesitter_try_attach(buf, language)
    elseif can_compile() and vim.tbl_contains(available_parsers, language) then
      -- Thiếu parser nhưng máy compile được → cài rồi attach
      require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
    else
      -- Không compile được (vd Windows thiếu MSVC): thử attach bằng parser runtime nếu có, không thì no-op
      treesitter_try_attach(buf, language)
    end
  end,
})
