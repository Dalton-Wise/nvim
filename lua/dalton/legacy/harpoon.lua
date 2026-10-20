-- Preserved bookmarks setup; not imported by lazy.nvim.
return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>A", function() require("harpoon"):list():prepend() end },
            { "<leader>a", function() require("harpoon"):list():add() end },
            { "<C-e>", function()
                local harpoon = require("harpoon")
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end },
            { "<C-j>", function() require("harpoon"):list():select(1) end },
            { "<C-k>", function() require("harpoon"):list():select(2) end },
            { "<C-l>", function() require("harpoon"):list():select(3) end },
            { "<C-;>", function() require("harpoon"):list():select(4) end },
            { "<leader><C-j>", function() require("harpoon"):list():replace_at(1) end },
            { "<leader><C-k>", function() require("harpoon"):list():replace_at(2) end },
            { "<leader><C-l>", function() require("harpoon"):list():replace_at(3) end },
            { "<leader><C-;>", function() require("harpoon"):list():replace_at(4) end },
        },
        config = function()
            require("harpoon"):setup({})
        end,
    },
}
