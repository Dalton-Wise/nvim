-- Run with: nvim --headless -u NONE -i NONE -l tests/test_tuicr.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath:prepend(root)
require("dalton.remap")
local open = vim.fn.maparg("<leader>gr", "n", false, true).callback
assert(type(open) == "function", "Space-gr must open tuicr")

local tmp = vim.fn.resolve(vim.fn.tempname())
local bin, repo, log = tmp .. "/bin", tmp .. "/repo", tmp .. "/log"
vim.fn.mkdir(bin, "p")
vim.fn.mkdir(repo .. "/src", "p")
vim.fn.writefile(
    { "#!/bin/sh", 'printf "%s\\n%s\\n" "$(pwd -P)" "$*" > "$TUICR_LOG"', 'exit "$TUICR_EXIT"' },
    bin .. "/tuicr"
)
vim.fn.setfperm(bin .. "/tuicr", "rwxr-xr-x")
vim.env.PATH = bin .. ":" .. vim.env.PATH
vim.env.TUICR_LOG = log
assert(vim.system({ "git", "init", "-q", repo }):wait().code == 0)
vim.cmd.edit(repo .. "/src/Main.java")
local editor = vim.api.nvim_get_current_win()
-- Odd dimensions catch margins that round unevenly.
vim.o.lines, vim.o.columns = 51, 161

local function assert_centered(win)
    local config = vim.api.nvim_win_get_config(win)
    -- The rounded border adds a cell on every side of the content.
    local bottom = vim.o.lines - config.row - config.height - 2
    local right = vim.o.columns - config.col - config.width - 2
    assert(config.row > 0 and config.row == bottom, "tuicr must have equal top and bottom margins")
    assert(config.col > 0 and config.col == right, "tuicr must have equal left and right margins")
end

local function run(code)
    vim.env.TUICR_EXIT = tostring(code)
    vim.fn.delete(log)
    open()
    local float = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(float)
    assert(vim.api.nvim_win_get_config(float).relative == "editor", "tuicr must open in a floating window")
    assert(vim.bo[buf].buftype == "terminal", "tuicr must run in a terminal")
    assert_centered(float)
    local channel = vim.bo[buf].channel
    assert(vim.wait(5000, function() return vim.fn.jobwait({ channel }, 0)[1] ~= -1 end), "tuicr did not exit")
    assert(
        vim.deep_equal(vim.fn.readfile(log), { repo, "-w" }),
        "tuicr must review uncommitted changes from the repo root"
    )
    return float, buf
end

local float, buf = run(0)
assert(vim.wait(1000, function() return not vim.api.nvim_win_is_valid(float) end), "A clean exit must close the float")
assert(not vim.api.nvim_buf_is_valid(buf), "A clean exit must wipe the terminal buffer")
assert(vim.api.nvim_get_current_win() == editor, "Closing tuicr must return focus to the editor")

float = run(1)
vim.wait(200)
assert(vim.api.nvim_win_is_valid(float), "A failed run must stay open so its error is readable")

vim.o.lines, vim.o.columns = 40, 120
vim.api.nvim_exec_autocmds("VimResized", {})
assert_centered(float)

vim.fn.delete(tmp, "rf")
print("PASS: tuicr float, centring, resizing, repo root, working-tree review and exit handling")
