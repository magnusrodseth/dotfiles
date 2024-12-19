-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "j", "jzz")
vim.keymap.set("n", "k", "kzz")

-- Loop to create keymaps for switching buffers using <leader>1 to <leader>9 and <leader>0 with :BufferLineGoToBuffer
for i = 1, 9 do
  vim.keymap.set("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "Go to Buffer " .. i })
end

-- Map <leader>0 to the 10th buffer
vim.keymap.set("n", "<leader>0", "<cmd>BufferLineGoToBuffer 10<CR>", { desc = "Go to Buffer 10" })
