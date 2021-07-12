local lspconfig = require('lspconfig')
local lsp_status = require('lsp-status')

lsp_status.config({
  indicator_errors = ' ',
  indicator_hint = ' ',
  indicator_info = ' ',
  indicator_ok = ' ',
  indicator_warnings = ' ',
  status_symbol = ''
})
lsp_status.register_progress()

local function lsp_attach(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local opts = { noremap=true, silent=true }

  buf_set_keymap('n', '<C-]>', '<cmd>Telescope lsp_definitions<CR>', opts)
  buf_set_keymap('n', '<A-CR>', '<cmd>Telescope lsp_code_actions<CR>', opts)
  buf_set_keymap('n', '<Leader>ld', '<cmd>Telescope lsp_document_diagnostics<CR>', opts)
  buf_set_keymap('n', '<Leader>lD', '<cmd>Telescope lsp_workspace_diagnostics<CR>', opts)
  buf_set_keymap('n', '<Leader>li', '<cmd>Telescope lsp_implementations<CR>', opts)
  buf_set_keymap('n', '<Leader>lr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<Leader>ls', '<cmd>Telescope lsp_document_symbols<CR>', opts)
  buf_set_keymap('n', '<Leader>lS', '<cmd>Telescope lsp_workspace_symbols<CR>', opts)
  buf_set_keymap('n', '<Leader>lt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>Telescope lsp_references<CR>', opts)
  buf_set_keymap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '[l', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']l', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)

  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<A-l>", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    buf_set_keymap("n", "<Leader>lf", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end
  if client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("v", "<A-l>", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
    buf_set_keymap("v", "<Leader>lf", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

  lsp_status.on_attach(client)
end

lspconfig.util.default_config = vim.tbl_extend(
  "force",
  lspconfig.util.default_config,
  {
    capabilities = lsp_status.capabilities,
    flags = { debounce_text_changes = 100 },
    on_attach = lsp_attach
  }
)

local servers = { "bashls", "cssls", "gopls", "html", "rnix", "tsserver" }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {}
end

lspconfig.metals.setup {
  root_dir = lspconfig.util.root_pattern("build.sbt", "build.sc", ".git")
}

local luadev = require("lua-dev").setup();
lspconfig.sumneko_lua.setup(luadev)

if vim.fn.executable('pyls') == 1 then
  lspconfig.pyls.setup {}
end
