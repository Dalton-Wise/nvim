return {
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
            on_attach = function(buffer)
                local gs = require("gitsigns")
                local function map(key, action, desc, mode)
                    vim.keymap.set(mode or "n", key, action, { buffer = buffer, desc = "Git: " .. desc })
                end
                map("gb", gs.blame_line, "Blame line")
                map("]c", function() gs.nav_hunk("next") end, "Next hunk")
                map("[c", function() gs.nav_hunk("prev") end, "Previous hunk")
                map("<leader>hp", gs.preview_hunk, "Preview hunk")
                map("<leader>hs", gs.stage_hunk, "Stage hunk")
                map("<leader>hr", gs.reset_hunk, "Reset hunk")
            end,
        },
    },
    {
        "kdheepak/lazygit.nvim",
        cmd = "LazyGit",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = { { "<leader>gg", "<cmd>LazyGit<CR>", desc = "Open LazyGit" } },
    },
}
