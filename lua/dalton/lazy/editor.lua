return {
    { "NMAC427/guess-indent.nvim", opts = {} },
    {
        "folke/todo-comments.nvim",
        event = "VimEnter",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = { signs = false },
    },
    {
        "echasnovski/mini.nvim",
        config = function()
            require("mini.ai").setup({ n_lines = 500 })
            require("mini.surround").setup()
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        -- main requires Neovim 0.12; master retains the 0.11-compatible API.
        branch = "master",
        lazy = false,
        build = ":TSUpdate",
        main = "nvim-treesitter.configs",
        opts = {
            ensure_installed = {
                "bash",
                "c",
                "diff",
                "html",
                "java",
                "kotlin",
                "json",
                "lua",
                "luadoc",
                "markdown",
                "markdown_inline",
                "query",
                "vim",
                "vimdoc",
            },
            auto_install = true,
            highlight = { enable = true, additional_vim_regex_highlighting = { "ruby" } },
            indent = { enable = true, disable = { "ruby" } },
        },
    },
}
