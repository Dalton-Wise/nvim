vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("DaltonHighlightYank", { clear = true }),
    desc = "Highlight copied text",
    callback = function() vim.hl.on_yank() end,
})
