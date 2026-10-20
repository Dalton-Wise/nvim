return {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewStop" },
    ft = "markdown",
    build = "cd app && ./install.sh",
    init = function() vim.g.mkdp_filetypes = { "markdown" } end,
    keys = { { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Toggle Markdown preview" } },
}
