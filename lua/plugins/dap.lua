return {
  -- nvim-dap: core Debug Adapter Protocol client
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- Mason integration: auto-install debug adapters
      {
        'jay-babu/mason-nvim-dap.nvim',
        dependencies = { 'williamboman/mason.nvim' },
        opts = {
          -- Auto-install these debug adapters via Mason
          ensure_installed = { 'python', 'js' },
          -- Automatic configuration of adapters that are set up via mason
          automatic_installation = true,
          -- Provide default handler + per-adapter overrides
          handlers = {},
        },
      },

      -- Debug UI: variable inspector, call stack, breakpoints, watches, console
      {
        'rcarriga/nvim-dap-ui',
        dependencies = { 'nvim-neotest/nvim-nio' },
        keys = {
          { '<leader>du', function() require('dapui').toggle() end, desc = 'Debug: Toggle UI' },
          { '<leader>de', function() require('dapui').eval() end,   desc = 'Debug: Eval',     mode = { 'n', 'v' } },
        },
        opts = {},
        config = function(_, opts)
          local dap = require('dap')
          local dapui = require('dapui')
          dapui.setup(opts)

          -- Auto open/close UI when debug session starts/ends
          dap.listeners.after.event_initialized['dapui_config'] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated['dapui_config'] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited['dapui_config'] = function()
            dapui.close()
          end
        end,
      },

      -- Virtual text: show variable values inline next to source code
      {
        'theHamsta/nvim-dap-virtual-text',
        opts = {},
      },
    },

    -- stylua: ignore
    keys = {
      { '<leader>db', function() require('dap').toggle_breakpoint() end,                                    desc = 'Debug: Toggle [B]reakpoint' },
      { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = 'Debug: Conditional [B]reakpoint' },
      { '<leader>dc', function() require('dap').continue() end,                                             desc = 'Debug: [C]ontinue / Start' },
      { '<leader>di', function() require('dap').step_into() end,                                            desc = 'Debug: Step [I]nto' },
      { '<leader>do', function() require('dap').step_over() end,                                            desc = 'Debug: Step [O]ver' },
      { '<leader>dO', function() require('dap').step_out() end,                                             desc = 'Debug: Step [O]ut' },
      { '<leader>dr', function() require('dap').repl.toggle() end,                                          desc = 'Debug: Toggle [R]EPL' },
      { '<leader>dl', function() require('dap').run_last() end,                                             desc = 'Debug: Run [L]ast' },
      { '<leader>dt', function() require('dap').terminate() end,                                            desc = 'Debug: [T]erminate' },
      { '<leader>dk', function() require('dap.ui.widgets').hover() end,                                     desc = 'Debug: Hover Variable' },
      { '<leader>dp', function() require('dap').pause() end,                                                desc = 'Debug: [P]ause' },
      { '<leader>dj', function() require('dap').down() end,                                                 desc = 'Debug: Stack Down' },
      { '<leader>dK', function() require('dap').up() end,                                                   desc = 'Debug: Stac[K] Up' },
      { '<F5>',       function() require('dap').continue() end,                                             desc = 'Debug: Continue' },
      { '<F10>',      function() require('dap').step_over() end,                                            desc = 'Debug: Step Over' },
      { '<F11>',      function() require('dap').step_into() end,                                            desc = 'Debug: Step Into' },
      { '<F12>',      function() require('dap').step_out() end,                                             desc = 'Debug: Step Out' },
    },

    config = function()
      local dap = require('dap')

      -- =====================================================================
      -- Signs: Customize breakpoint & debug indicators in the sign column
      -- =====================================================================
      vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DiagnosticError', linehl = '', numhl = '' })
      vim.fn.sign_define('DapBreakpointCondition', { text = '', texthl = 'DiagnosticWarn', linehl = '', numhl = '' })
      vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DiagnosticInfo', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '', texthl = 'DiagnosticOk', linehl = 'DapStoppedLine', numhl = '' })
      vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DiagnosticError', linehl = '', numhl = '' })

      -- Highlight the line where the debugger is stopped
      vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })

      -- =====================================================================
      -- Python (debugpy)
      -- =====================================================================
      -- mason-nvim-dap handles adapter registration automatically.
      -- We just define launch configurations here.
      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          pythonPath = function()
            -- Use activated virtualenv if present, otherwise fall back to system python
            local venv = os.getenv('VIRTUAL_ENV')
            if venv then
              return venv .. '/bin/python'
            end
            local conda = os.getenv('CONDA_PREFIX')
            if conda then
              return conda .. '/bin/python'
            end
            return '/usr/bin/python3'
          end,
        },
        {
          type = 'python',
          request = 'launch',
          name = 'Launch file with arguments',
          program = '${file}',
          args = function()
            local input = vim.fn.input('Arguments: ')
            return vim.split(input, ' ', { trimempty = true })
          end,
          pythonPath = function()
            local venv = os.getenv('VIRTUAL_ENV')
            if venv then
              return venv .. '/bin/python'
            end
            local conda = os.getenv('CONDA_PREFIX')
            if conda then
              return conda .. '/bin/python'
            end
            return '/usr/bin/python3'
          end,
        },
        {
          type = 'python',
          request = 'attach',
          name = 'Attach to running process',
          connect = function()
            local host = vim.fn.input('Host [127.0.0.1]: ')
            host = host ~= '' and host or '127.0.0.1'
            local port = tonumber(vim.fn.input('Port [5678]: ')) or 5678
            return { host = host, port = port }
          end,
        },
      }

      -- =====================================================================
      -- JavaScript / TypeScript (js-debug-adapter)
      -- =====================================================================
      -- mason-nvim-dap handles adapter registration automatically.
      -- We define launch configurations for Node.js and Chrome.
      for _, lang in ipairs({ 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' }) do
        dap.configurations[lang] = {
          {
            type = 'js-debug-adapter',
            request = 'launch',
            name = 'Launch file (Node)',
            program = '${file}',
            cwd = '${workspaceFolder}',
          },
          {
            type = 'js-debug-adapter',
            request = 'attach',
            name = 'Attach to Node process',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
          },
          {
            type = 'js-debug-adapter',
            request = 'launch',
            name = 'Launch Chrome (localhost:3000)',
            url = 'http://localhost:3000',
            webRoot = '${workspaceFolder}',
          },
        }
      end
    end,
  },
}
