return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = { options = vim.opt.sessionoptions:get() },
  -- stylua: ignore
  keys = {
    { "<leader>sr", function() require("persistence").load() end,                desc = "[S]ession [R]estore" },
    { "<leader>sl", function() require("persistence").load({ last = true }) end, desc = "[S]ession [L]ast Active" },
  },
}
