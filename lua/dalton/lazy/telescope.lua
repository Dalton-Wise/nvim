local function picker(name, options)
    return function() require("telescope.builtin")[name](options or {}) end
end

local function selection_window(picker)
    local sidebar = picker.original_win_id
    local buffer = vim.api.nvim_win_get_buf(sidebar)
    if vim.bo[buffer].filetype ~= "neo-tree" then
        return 0 -- Keep normal Telescope behavior outside the sidebar.
    end

    local function is_editor(win)
        return vim.api.nvim_win_is_valid(win)
            and vim.api.nvim_win_get_config(win).relative == ""
            and vim.bo[vim.api.nvim_win_get_buf(win)].buftype == ""
            and not vim.wo[win].winfixbuf
    end

    -- Prefer the editor most recently focused before the sidebar.
    local previous = require("neo-tree").get_prior_window({}, true)
    if previous > 0 and is_editor(previous) then
        return previous
    end

    -- Otherwise reuse any available editor in this tab.
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if is_editor(win) then
            return win
        end
    end

    -- Only the sidebar remains: create an editor and restore sidebar width.
    vim.cmd("rightbelow vnew")
    local editor = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(sidebar, 40)
    return editor
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
                get_selection_window = selection_window,
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
