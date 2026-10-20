-- Preserved worktree setup; not imported by lazy.nvim.
return {
    {
        "ThePrimeagen/git-worktree.nvim",
        dependencies = { 'nvim-telescope/telescope.nvim' },
        branch = "master",
        keys = {
            { "<leader><C-w>", function() require("telescope").extensions.git_worktree.git_worktrees() end },
            { "<leader><C-n>", function() require("telescope").extensions.git_worktree.create_git_worktree() end },
        },
        config = function()
            require("telescope").load_extension("git_worktree")
        end
    }
}
