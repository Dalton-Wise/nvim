local M = {}

local function geometry()
    local row, col = math.floor(vim.o.lines * 0.05), math.floor(vim.o.columns * 0.05)
    -- The rounded border adds a cell on every side of the content.
    return {
        relative = "editor",
        row = row,
        col = col,
        height = vim.o.lines - 2 * row - 2,
        width = vim.o.columns - 2 * col - 2,
    }
end

function M.open()
    if vim.fn.executable("tuicr") == 0 then
        vim.notify("tuicr is not installed", vim.log.levels.WARN)
        return
    end
    local file = vim.api.nvim_buf_get_name(0)
    local cwd = vim.fn.getcwd()
    local root = vim.fs.root(file ~= "" and vim.fs.dirname(file) or cwd, ".git") or cwd
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(
        buf,
        true,
        vim.tbl_extend("force", geometry(), {
            style = "minimal",
            border = "rounded",
        })
    )
    vim.api.nvim_create_autocmd("VimResized", {
        callback = function()
            if not vim.api.nvim_win_is_valid(win) then return true end
            vim.api.nvim_win_set_config(win, geometry())
        end,
    })
    vim.fn.jobstart({ "tuicr", "-w" }, {
        term = true,
        cwd = root,
        on_exit = function(_, code)
            -- Failures stay open so tuicr's error message is readable.
            if code == 0 and vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
        end,
    })
    vim.cmd.startinsert()
end

return M
