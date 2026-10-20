return {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
        { "L3MON4D3/LuaSnip", version = "2.*", opts = {} },
        { "folke/lazydev.nvim", ft = "lua", opts = {} },
    },
    opts = {
        keymap = { preset = "default" },
        appearance = { nerd_font_variant = "mono" },
        completion = { documentation = { auto_show = false } },
        sources = {
            default = { "lsp", "path", "snippets", "lazydev" },
            providers = {
                lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
            },
        },
        snippets = { preset = "luasnip" },
        fuzzy = { implementation = "lua" },
        signature = { enabled = true },
    },
}
