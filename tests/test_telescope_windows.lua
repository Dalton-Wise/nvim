-- Run with: nvim --headless -u NONE -i NONE -l tests/test_telescope_windows.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local previous = -1
package.loaded["telescope.themes"] = { get_dropdown = function() return {} end }
package.loaded["neo-tree"] = { get_prior_window = function() return previous end }
local select_window = dofile(root .. "/lua/dalton/lazy/telescope.lua").opts().defaults.get_selection_window
assert(type(select_window) == "function", "Telescope must select an editor window when launched from Neo-tree")

local function sidebar_only()
    vim.cmd("silent only!")
    vim.cmd("enew")
    vim.bo.buftype = "nofile"
    vim.bo.filetype = "neo-tree"
    vim.wo.winfixbuf = false
    vim.wo.winfixwidth = true
    previous = -1
    return vim.api.nvim_get_current_win()
end

local function new_editor()
    vim.cmd("rightbelow vnew")
    return vim.api.nvim_get_current_win()
end

-- Launching from a normal editor keeps Telescope's default behavior.
local editor = vim.api.nvim_get_current_win()
assert(select_window({ original_win_id = editor }) == 0)
assert(#vim.api.nvim_tabpage_list_wins(0) == 1)

-- A full-width sidebar must become a sidebar again, leaving room for the file.
local sidebar = sidebar_only()
editor = select_window({ original_win_id = sidebar })
assert(editor ~= sidebar and vim.api.nvim_win_is_valid(editor))
assert(vim.api.nvim_get_current_win() == editor)
assert(#vim.api.nvim_tabpage_list_wins(0) == 2)
assert(vim.api.nvim_win_get_width(sidebar) == 40)
assert(
    vim.api.nvim_win_get_width(editor) == vim.o.columns - 41,
    string.format(
        "The file must get the remaining space (columns=%d, sidebar=%d, editor=%d)",
        vim.o.columns,
        vim.api.nvim_win_get_width(sidebar),
        vim.api.nvim_win_get_width(editor)
    )
)
assert(vim.bo[vim.api.nvim_win_get_buf(editor)].buftype == "")

-- Reuse the last focused editor, not another editor or a new split.
sidebar = sidebar_only()
editor = new_editor()
local other = new_editor()
previous = other
vim.api.nvim_set_current_win(sidebar)
assert(select_window({ original_win_id = sidebar }) == other)
assert(#vim.api.nvim_tabpage_list_wins(0) == 3)

-- A closed prior window falls back to an existing editor.
vim.api.nvim_win_close(other, true)
vim.api.nvim_set_current_win(sidebar)
assert(select_window({ original_win_id = sidebar }) == editor)
assert(#vim.api.nvim_tabpage_list_wins(0) == 2)

-- Floating previews must never be used as the destination.
local floating = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), false, {
    relative = "editor",
    row = 1,
    col = 1,
    width = 20,
    height = 5,
    style = "minimal",
})
previous = floating
assert(select_window({ original_win_id = sidebar }) == editor)
assert(#vim.api.nvim_tabpage_list_wins(0) == 3)
vim.api.nvim_win_close(floating, true)

-- Special buffers and buffer-locked windows are not reusable editors.
for _, kind in ipairs({ "special", "locked" }) do
    sidebar = sidebar_only()
    local blocked = new_editor()
    if kind == "special" then
        vim.bo.buftype = "nofile"
    else
        vim.wo.winfixbuf = true
    end
    previous = blocked
    vim.api.nvim_set_current_win(sidebar)
    editor = select_window({ original_win_id = sidebar })
    assert(editor ~= blocked and editor ~= sidebar, "Must not replace a " .. kind .. " window")
    assert(#vim.api.nvim_tabpage_list_wins(0) == 3)
end

print("PASS: Telescope editor reuse, sidebar width, closed windows, floats and protected buffers")
