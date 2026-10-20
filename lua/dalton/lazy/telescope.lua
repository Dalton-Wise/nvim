local function picker(name, options)
    return function() require("telescope.builtin")[name](options or {}) end
end

return {
    "nvim-telescope/telescope.nvim",
    -- This known-working revision supports Neovim 0.11.6 and filename_first.
    commit = "3333a52ff548ba0a68af6d8da1e54f9cd96e9179",
    event = "VimEnter",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
            cond = function() return vim.fn.executable("make") == 1 end,
        },
        "nvim-telescope/telescope-ui-select.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    opts = function()
        return {
            defaults = {
                path_display = { "filename_first" },
                file_ignore_patterns = { "^build/", "/build/", "^bin/", "/bin/" },
            },
            extensions = { ["ui-select"] = { require("telescope.themes").get_dropdown() } },
        }
    end,
    config = function(_, opts)
        local telescope = require("telescope")
        telescope.setup(opts)
        pcall(telescope.load_extension, "fzf")
        telescope.load_extension("ui-select")
    end,
    keys = {
        { "<leader>sh", picker("help_tags"), desc = "Search help" },
        { "<leader>sk", picker("keymaps"), desc = "Search keymaps" },
        { "<leader>sf", picker("find_files"), desc = "Search files" },
        { "<leader>ss", picker("builtin"), desc = "Search Telescope pickers" },
        { "<leader>sw", picker("grep_string"), desc = "Search current word" },
        { "<leader>sg", picker("live_grep"), desc = "Search by grep" },
        { "<leader>sd", picker("diagnostics"), desc = "Search diagnostics" },
        { "<leader>sr", picker("resume"), desc = "Resume search" },
        { "<leader>s.", picker("oldfiles"), desc = "Search recent files" },
        { "<leader><leader>", picker("buffers"), desc = "Find open buffers" },
        {
            "<leader>/",
            function()
                require("telescope.builtin").current_buffer_fuzzy_find(
                    require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })
                )
            end,
            desc = "Search current buffer",
        },
        {
            "<leader>s/",
            picker("live_grep", { grep_open_files = true, prompt_title = "Grep Open Files" }),
            desc = "Search open files",
        },
        { "<leader>sn", picker("find_files", { cwd = vim.fn.stdpath("config") }), desc = "Search Neovim config" },
        { "gf", picker("find_files"), desc = "Find file" },
        { "gz", picker("live_grep"), desc = "Grep project" },
    },
}
