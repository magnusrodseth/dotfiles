return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  build = ':Copilot auth',
  config = function()
    require('copilot').setup {
      keymap = {
        accept = '<tab>',
      },
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = '<tab>',
          next = '<C-n>',
          prev = '<C-p>',
        },
      },
      filetypes = {
        yaml = false,
        markdown = false,
        help = false,
        gitcommit = false,
        gitrebase = false,
        hgcommit = false,
        svn = false,
        cvs = false,
        sh = function()
          if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then
            -- disable for .env files
            return false
          end
          return true
        end,
      },
    }
  end,
}
