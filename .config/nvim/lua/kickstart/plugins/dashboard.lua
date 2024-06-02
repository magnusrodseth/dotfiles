return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup {
      theme = 'hyper',
      config = {
        week_header = {
          enable = true,
        },
        shortcut = {
          {
            desc = 'Update',
            action = 'Lazy update',
            key = 'u',
          },
          {
            desc = 'Files',
            action = 'Telescope find_files',
            key = 'f',
          },
          {
            desc = 'Grep',
            action = 'Telescope live_grep',
            key = 'g',
          },
          {
            desc = 'Explorer',
            action = 'Neotree toggle',
            key = 'e',
          },
        },
      },
    }
  end,
  dependencies = { { 'nvim-tree/nvim-web-devicons' } },
}
