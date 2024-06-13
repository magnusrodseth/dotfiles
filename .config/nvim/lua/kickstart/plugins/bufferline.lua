return {
  'akinsho/bufferline.nvim',
  event = "VeryLazy",
  keys = {
    -- close buffer with bw
    { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>",   desc = "Delete [O]ther Buffers" },
    { "<leader>br", "<Cmd>BufferLineCloseRight<CR>",    desc = "Delete [B]uffers to the [R]ight" },
    { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>",     desc = "Delete [B]uffers to the [L]eft" },
    { "<leader>1",  "<cmd>BufferLineGoToBuffer 1<cr>",  desc = "Go to buffer [1]" },
    { "<leader>2",  "<cmd>BufferLineGoToBuffer 2<cr>",  desc = "Go to buffer [2]" },
    { "<leader>3",  "<cmd>BufferLineGoToBuffer 3<cr>",  desc = "Go to buffer [3]" },
    { "<leader>4",  "<cmd>BufferLineGoToBuffer 4<cr>",  desc = "Go to buffer [4]" },
    { "<leader>5",  "<cmd>BufferLineGoToBuffer 5<cr>",  desc = "Go to buffer [5]" },
    { "<leader>6",  "<cmd>BufferLineGoToBuffer 6<cr>",  desc = "Go to buffer [6]" },
    { "<leader>7",  "<cmd>BufferLineGoToBuffer 7<cr>",  desc = "Go to buffer [7]" },
    { "<leader>8",  "<cmd>BufferLineGoToBuffer 8<cr>",  desc = "Go to buffer [8]" },
    { "<leader>9",  "<cmd>BufferLineGoToBuffer 9<cr>",  desc = "Go to buffer [9]" },
    { "<leader>0",  "<cmd>BufferLineGoToBuffer 10<cr>", desc = "Go to buffer [10]" },
  },
  opts = {
    options = {
      -- stylua: ignore
      close_command = function(n) vim.ui.bufremove(n) end,
      -- stylua: ignore
      right_mouse_command = function(n) vim.ui.bufremove(n) end,
      diagnostics = "nvim_lsp",
      always_show_bufferline = false,
      offsets = {
        {
          filetype = "neo-tree",
          text = "Neo-tree",
          highlight = "Directory",
          text_align = "left",
        },
      },
    },
  },
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function(_, opts)
    require("bufferline").setup(opts)
    -- Fix bufferline when restoring a session
    vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
      callback = function()
        vim.schedule(function()
          pcall(nvim_bufferline)
        end)
      end,
    })
  end,
}
