local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = '/home/rcook/.local/eclipse' .. project_name
local jdtls = require('jdtls')

local config = {
    cmd = { 'jdt-language-server', '-data', workspace_dir },
    root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1]),
    on_attach = function(_, bufnr)
        local opts = { silent = true, buffer = nil }

        require('lsp_mappings/keymaps')

        vim.keymap.set('n', '<leader>oi', jdtls.organize_imports, opts)
        vim.keymap.set('n', '<leader>dt', jdtls.test_class, opts)
        -- vim.keymap.set('n', '<leader>gt', vim.cmd("lua require('jdtls.tests').generate()"), opts)
        vim.keymap.set('n', '<leader>gt', function()
            require('jdtls.tests').generate()
        end, opts)
        -- vim.keymap.set('n', '<leader>gsub', vim.cmd("lua require('jdtls.tests').goto_subjects()"), opts)
        vim.keymap.set('n', '<leader>gsub', function()
            require('jdtls.tests').goto_subjects()
        end, opts)
        vim.keymap.set('n', '<leader>dm', jdtls.test_nearest_method, opts)
        vim.keymap.set('n', '<leader>xv', jdtls.extract_variable, opts)
        -- vim.keymap.set('v', '<leader>xm', vim.cmd("lua require('jdtls').extract_method(true)"), opts)
        vim.keymap.set('v', '<leader>xm', function()
            require('jdtls').extract_method(true)
        end, opts)
        vim.keymap.set('n', '<leader>xc', jdtls.extract_constant, opts)

        -- Remove unused imports
        vim.keymap.set('n', '<leader>rui', function()
            vim.diagnostic.setqflist { severity = vim.diagnostic.severity.WARN }
            vim.cmd('packadd cfilter')
            vim.cmd('Cfilter /main/')
            vim.cmd('Cfilter /The import/')
            vim.cmd('cdo normal dd')
            vim.cmd('cclose')
            vim.cmd('wa')
        end, opts)
    end
}

local bundles = {
    vim.fn.glob(
        "./dap/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar",
        true)
}

vim.list_extend(bundles, vim.split(vim.fn.glob("./dap/vscode-java-test/server/*.jar", true), "\n"))

config["init_options"] = {
    bundles = bundles
}

require('jdtls.setup').add_commands()
require('jdtls').start_or_attach(config)
require('jdtls.dap').setup_dap(config)
