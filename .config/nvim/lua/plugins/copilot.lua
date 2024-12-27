return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      keymap = {
        accept = "<Tab>", -- Map the Tab key to accept the suggestion
        next = "<C-n>",
        prev = "<C-p>",
      },
      display = {
        format = "virtual_text", -- Use virtual text for displaying suggestions
      },
    },
    panel = { enabled = false },
    filetypes = {
      markdown = true,
      help = true,
    },
  },
}
