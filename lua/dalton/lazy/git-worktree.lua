return {
    {
        "ThePrimeagen/git-worktree.nvim",
        dependencies = { 'nvim-telescope/telescope.nvim' },
        branch = "master",
        config = function()
            print('configuring git worktree plugin')

            local telescope = require("telescope")
            telescope.load_extension("git_worktree")
            vim.keymap.set("n", "<leader><c-W>", function() telescope.extensions.git_worktree.git_worktrees() end)
            vim.keymap.set("n", "<leader><c-N>", function() telescope.extensions.git_worktree.create_git_worktree() end)

        end
    }
}
