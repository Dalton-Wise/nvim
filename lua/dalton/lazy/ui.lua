return {
    {
        "folke/which-key.nvim",
        event = "VimEnter",
        opts = {
            delay = 0,
            icons = { mappings = vim.g.have_nerd_font },
            spec = {
                { "<leader>c", group = "Call hierarchy" },
                { "<leader>g", group = "Git" },
                { "<leader>h", group = "Git hunks", mode = { "n", "v" } },
                { "<leader>m", group = "Markdown" },
                { "<leader>s", group = "Search" },
                { "<leader>t", group = "Toggle / type hierarchy" },
                { "<leader>w", group = "Workspace" },
            },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = { options = { theme = "auto" } },
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        version = "*",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
        lazy = false,
        keys = { { "\\", "<cmd>Neotree reveal<CR>", desc = "Reveal file in Neo-tree", silent = true } },
        opts = { filesystem = { window = { mappings = { ["\\"] = "close_window" } } } },
    },
}
