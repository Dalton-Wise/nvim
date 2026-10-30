-- Run with: nvim --headless -u NONE -i NONE -l tests/test_zoom.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath:prepend(root)
require("dalton.remap")
local toggle = vim.fn.maparg("<leader>z", "n", false, true).callback
assert(type(toggle) == "function", "Space-z must toggle window zoom")

vim.o.columns = 160
vim.o.lines = 50

local function sizes()
    local result = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_config(win).relative == "" then
            result[win] = { vim.api.nvim_win_get_width(win), vim.api.nvim_win_get_height(win) }
        end
    end
    return result
end

-- A fixed-width Neo-tree sidebar must return to its exact original size.
local sidebar = vim.api.nvim_get_current_win()
vim.bo.buftype = "nofile"
vim.bo.filetype = "neo-tree"
vim.wo.winfixwidth = true
vim.cmd("rightbelow vnew")
local editor = vim.api.nvim_get_current_win()
vim.cmd("belowright new")
vim.api.nvim_win_set_height(0, 12)
vim.api.nvim_win_set_width(sidebar, 37)
vim.api.nvim_set_current_win(sidebar)
local original = sizes()
local layout = vim.fn.winlayout()
for _ = 1, 2 do
    toggle()
    assert(vim.api.nvim_win_get_width(sidebar) > original[sidebar][1], "Sidebar must expand")
    assert(vim.deep_equal(layout, vim.fn.winlayout()), "Zoom must preserve the split layout")
    assert(vim.api.nvim_get_current_win() == sidebar, "Zoom must preserve focus")
    toggle()
    assert(vim.deep_equal(original, sizes()), "Unzoom must restore all original window sizes exactly")
    assert(vim.wo.winfixwidth, "Zoom must preserve Neo-tree's fixed-width option")
end

-- Editor panes expand in both dimensions and can be restored from another window.
vim.api.nvim_set_current_win(editor)
toggle()
assert(vim.api.nvim_win_get_width(editor) > original[editor][1], "Editor must expand horizontally")
assert(vim.api.nvim_win_get_height(editor) > original[editor][2], "Editor must expand vertically")
vim.api.nvim_set_current_win(sidebar)
toggle()
assert(vim.deep_equal(original, sizes()), "Restoring from another pane must restore the same layout")

-- Floating windows must not affect the tiled layout or its saved zoom state.
toggle()
local zoomed = sizes()
local floating = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
    relative = "editor",
    row = 1,
    col = 1,
    width = 20,
    height = 5,
    style = "minimal",
})
toggle()
assert(vim.deep_equal(zoomed, sizes()), "Floating windows must not alter the zoomed splits")
vim.api.nvim_win_close(floating, true)
vim.api.nvim_set_current_win(sidebar)
toggle()
assert(vim.deep_equal(original, sizes()), "Ignoring a float must preserve the saved original sizes")

-- Each tab maintains its own independent saved layout.
toggle()
local first_tab = vim.api.nvim_get_current_tabpage()
vim.cmd("tabnew")
local single = sizes()
toggle()
assert(vim.deep_equal(single, sizes()), "Zooming a single window must be a no-op")
vim.cmd("vnew")
vim.api.nvim_win_set_width(0, 52)
local second_tab = vim.api.nvim_get_current_tabpage()
local second_original = sizes()
toggle()
assert(not vim.deep_equal(second_original, sizes()), "The second tab must zoom independently")
vim.api.nvim_set_current_tabpage(first_tab)
toggle()
assert(vim.deep_equal(original, sizes()), "Another tab must not overwrite the first tab's saved sizes")
vim.api.nvim_set_current_tabpage(second_tab)
toggle()
assert(vim.deep_equal(second_original, sizes()), "The second tab must restore its own original sizes")

-- Do not replay stale window-number resize commands after splits are closed or opened.
toggle()
vim.cmd("only")
toggle()
local after_close = sizes()
vim.cmd("vnew")
vim.api.nvim_win_set_width(0, 45)
local after_split = sizes()
assert(not vim.deep_equal(after_close, after_split))
toggle()
toggle()
assert(vim.deep_equal(after_split, sizes()), "New splits must get a fresh saved layout")

toggle()
vim.cmd("belowright new")
local changed = sizes()
toggle()
toggle()
assert(vim.deep_equal(changed, sizes()), "A changed split layout must replace stale saved sizes")

print("PASS: window zoom, exact size restoration, fixed-width sidebar, floats, tabs and layout changes")
