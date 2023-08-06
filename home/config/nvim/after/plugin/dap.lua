require("dapui").setup()

local dap, dapui = require('dap'), require('dapui')

dap.adapters.codelldb = {
    type = 'server',
    host = '127.0.0.1',
    port = "''${port}",
    executable = {
        command = '/home/rcook/.local/bin/codelldb',
        args = { "--port", "''${port}" },
    }
}


dap.configurations.rust = {
    {
        name = "Launch file",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = "''${workspaceFolder}",
        stopOnEntry = false,
    },
}

dap.configurations.java = {
    {
        name = "Attach to Jade",
        type = "java",
        request = "attach",
        hostName = "127.0.0.1",
        port = 8101,
    },
    {
        name = "Attach to Tigerlily",
        type = "java",
        request = "attach",
        hostName = "127.0.0.1",
        port = 8102,
    },
    {
        name = "Attach to XVPManager",
        type = "java",
        request = "attach",
        hostName = "127.0.0.1",
        port = 8103,
    },
}

vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F8>', function() require('dap').step_over() end)
vim.keymap.set('n', '<F7>', function() require('dap').step_into() end)
vim.keymap.set('n', '<S-F8>', function() require('dap').step_out() end)
vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint() end)
vim.keymap.set('n', '<Leader>lp',
    function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function()
    require('dap.ui.widgets').hover()
end)
vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function()
    require('dap.ui.widgets').preview()
end)
vim.keymap.set('n', '<Leader>df', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.frames)
end)
vim.keymap.set('n', '<Leader>ds', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.scopes)
end)

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end
