return {
    "neovim/nvim-lspconfig",
    version = "^2.0.0",
    lazy = false,
    dependencies = {
        { "mason-org/mason.nvim", version = "^2.0.0", opts = {} },
        { "mason-org/mason-lspconfig.nvim", version = "^2.0.0" },
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        "saghen/blink.cmp",
        { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
        require("dalton.lsp").setup()

        local servers = { "lua_ls", "pylsp", "gopls" }
        local capabilities = require("blink.cmp").get_lsp_capabilities()
        for _, name in ipairs(servers) do
            vim.lsp.config(name, { capabilities = capabilities })
        end
        vim.lsp.config("lua_ls", {
            settings = { Lua = { completion = { callSnippet = "Replace" } } },
        })

        -- IntelliJ owns Java/Kotlin. An old Mason JDTLS installation must stay inactive.
        vim.lsp.enable("jdtls", false)
        require("mason-tool-installer").setup({ ensure_installed = { "stylua" } })
        require("mason-lspconfig").setup({
            ensure_installed = servers,
            automatic_enable = servers,
        })
    end,
}
