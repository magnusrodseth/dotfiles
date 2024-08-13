return {
  'nvimdev/dashboard-nvim',
  lazy = false,
  event = 'VimEnter',
  opts = function()
    local function get_random_emoji()
      local emojis = { '🚀', '✨', '🎉', '🤠' }
      math.randomseed(os.time())
      return emojis[math.random(#emojis)]
    end
    local builtin = require 'telescope.builtin'
    local logo = get_random_emoji()

    logo = string.rep('\n', 8) .. logo .. '\n\n'

    local opts = {
      theme = 'doom',
      hide = {
        -- this is taken care of by lualine
        -- enabling this messes up the actual laststatus setting after loading a file
        statusline = false,
      },
      config = {
        header = vim.split(logo, '\n'),
        -- stylua: ignore
        center = {
          { action = builtin.find_files, desc = " Find File", icon = " ", key = "f" },
          { action = "ene | startinsert", desc = " New File", icon = " ", key = "n" },
          { action = builtin.oldfiles, desc = " Recent Files", icon = " ", key = "r" },
          { action = builtin.live_grep, desc = " Find Text", icon = " ", key = "g" },
          {
            action = function()
              builtin.find_files { cwd = vim.fn.stdpath 'config' }
            end,
            desc = " Config",
            icon = " ",
            key = "c"
          },
          { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
          { action = function() vim.api.nvim_input("<cmd>qa<cr>") end, desc = " Quit", icon = " ", key = "q" },
        },
        footer = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return { '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms' }
        end,
      },
    }

    for _, button in ipairs(opts.config.center) do
      button.desc = button.desc .. string.rep(' ', 43 - #button.desc)
      button.key_format = '  %s'
    end

    -- close Lazy and re-open when the dashboard is ready
    if vim.o.filetype == 'lazy' then
      vim.cmd.close()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'DashboardLoaded',
        callback = function()
          require('lazy').show()
        end,
      })
    end

    return opts
  end,
  dependencies = { { 'nvim-tree/nvim-web-devicons' } },
}
