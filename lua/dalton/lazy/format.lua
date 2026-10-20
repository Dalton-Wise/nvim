return {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
        {
            "<leader>f",
            function() require("conform").format({ lsp_format = "fallback" }) end,
            mode = { "n", "x" },
            desc = "Format buffer or selection",
        },
    },
    opts = {
        notify_on_error = true,
        format_on_save = function(bufnr)
            -- Java/Kotlin formatting remains explicit until checked against project rules.
            local manual = { c = true, cpp = true, java = true, kotlin = true }
            if manual[vim.bo[bufnr].filetype] then return nil end
            return { timeout_ms = 500, lsp_format = "fallback" }
        end,
        formatters_by_ft = { json = { "jq" }, lua = { "stylua" } },
        formatters = { jq = { args = { "--indent", "2" } } },
    },
}
