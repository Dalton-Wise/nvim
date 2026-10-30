local M = {}

function M.toggle()
    if vim.api.nvim_win_get_config(0).relative ~= "" then return end

    local saved = vim.t.dalton_zoom
    if saved then
        vim.t.dalton_zoom = nil
        -- Window numbers in winrestcmd() are only safe while the layout is unchanged.
        if vim.deep_equal(saved.layout, vim.fn.winlayout()) then
            vim.cmd(saved.restore)
            return
        end
    end

    if vim.fn.winnr("$") == 1 then return end

    vim.t.dalton_zoom = { layout = vim.fn.winlayout(), restore = vim.fn.winrestcmd() }
    vim.cmd("wincmd |")
    vim.cmd("wincmd _")
end

return M
