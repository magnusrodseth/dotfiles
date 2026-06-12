return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      window = {
        mappings = {
          ["\\"] = "close_window",
        },
      },
      follow_current_file = {
        enabled = true, -- This will find and focus the file in the active buffer every time
        leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
      },
      filtered_items = {
        visible = true, -- If you set this to `true`, all "hide" just means "dimmed out"
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
    window = {
      position = "right",
    },
  },
}
