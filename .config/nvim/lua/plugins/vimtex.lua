return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_context_pdf_viewer = "skim" -- external PDF viewer run from vimtex menu command
    vim.g.vimtex_view_skim_sync = 1 -- Value 1 allows forward search after every successful compilation
    vim.g.vimtex_view_skim_activate = 1 -- Value 1 allows change focus to skim after command `:VimtexView` is given

    vim.g.vimtex_quickfix_mode = 0 -- suppress error reporting on save and build
    vim.g.vimtex_mappings_enabled = 0 -- Ignore mappings
    vim.g.vimtex_indent_enabled = 0 -- Auto Indent
    vim.g.tex_flavor = "latex" -- how to read tex files
    vim.g.tex_indent_items = 0 -- turn off enumerate indent
    vim.g.tex_indent_brace = 0 -- turn off brace indent
    vim.g.vimtex_log_ignore = {
      "Underfull",
      "Overfull",
      "specifier changed to",
      "Token not allowed in a PDF string",
    }

    vim.g.vimtex_compiler_latexmk = {
      aux_dir = "out",
    }

    -- Use localleader + v to open Zathura and jump to the current location in the PDF
    vim.keymap.set("n", "<localleader><CR>", "<cmd>VimtexView<CR>", { desc = "Open TeX in PDF reader" })

    -- localleader + c to compile
    vim.keymap.set("n", "<localleader>c", "<cmd>VimtexCompile<CR>", { desc = "Compile TeX" })
  end,
}
