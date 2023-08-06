-- Set up lspconfig.
require("neodev").setup()

local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
local lsp = require('lspconfig')
lsp.volar.setup {
    init_options = {
        typescript = {
            tsdk = '/home/rcook/.npm-packages/lib/node_modules/typescript/lib'
        }
    },
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
    capabilities = capabilities
}

lsp.rust_analyzer.setup {
    settings = {
        ['rust_analyzer'] = {},
    }
}

lsp.lua_ls.setup {
    settings = {
        Lua = {
            competion = {
                callSnippet = "Replace",
            },
            workspace = {
                checkThirdParty = false,
            }
        },
    },
}

vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_next)
vim.keymap.set("n", "]d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function()
        require('lsp_mappings/keymaps')
    end,
})

vim.diagnostic.config({
    virtual_text = true
})
