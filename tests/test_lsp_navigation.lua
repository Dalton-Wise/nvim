-- Run with: nvim --headless -u NONE -i NONE -l tests/test_lsp_navigation.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
vim.g.mapleader = " "

local calls = {}
local telescope_loads = 0
local expected = {
    gd = "lsp_definitions",
    grd = "lsp_definitions",
    gi = "lsp_implementations",
    gri = "lsp_implementations",
    gu = "lsp_references",
    grr = "lsp_references",
    grt = "lsp_type_definitions",
    gO = "lsp_document_symbols",
    gW = "lsp_dynamic_workspace_symbols",
    [" ws"] = "lsp_dynamic_workspace_symbols",
}
package.preload["telescope.builtin"] = function()
    telescope_loads = telescope_loads + 1
    local builtins = {}
    for _, name in pairs(expected) do
        builtins[name] = function() table.insert(calls, name) end
    end
    return builtins
end

local supported = {}
vim.lsp.get_client_by_id = function(id)
    if id == 0 then return nil end
    return { supports_method = function(_, method) return supported[method] == true end }
end
local lsp = require("dalton.lsp")
lsp.setup()
local first = vim.api.nvim_create_buf(true, false)
local second = vim.api.nvim_create_buf(true, false)
local function mapping(buffer, key)
    return vim.api.nvim_buf_call(buffer, function() return vim.fn.maparg(key, "n", false, true) end)
end
local function attach(buffer, id)
    vim.api.nvim_exec_autocmds("LspAttach", { buffer = buffer, data = { client_id = id or 1 } })
end

attach(first, 0)
assert(telescope_loads == 0, "Attaching must not load Telescope")
for key, name in pairs(expected) do
    local bound = mapping(first, key)
    assert(bound.buffer == 1 and bound.desc, "Missing described buffer-local key: " .. key)
    bound.callback()
    assert(calls[#calls] == name, "Wrong picker for " .. key)
    assert(mapping(second, key).buffer ~= 1, "Mapping leaked to unattached buffer")
end
assert(telescope_loads == 1)
assert(mapping(first, " ci").buffer ~= 1, "Unsupported hierarchy must not be mapped")

supported = {
    ["textDocument/prepareCallHierarchy"] = true,
    ["textDocument/prepareTypeHierarchy"] = true,
    ["textDocument/documentHighlight"] = true,
    ["textDocument/inlayHint"] = true,
}
attach(second)
for _, key in ipairs({ " ci", " co", " ts", " tu", " th", "grn", "gra", "gh", "gH", "gp" }) do
    assert(mapping(second, key).buffer == 1, "Missing LSP feature: " .. key)
end
local enabled
vim.lsp.inlay_hint.is_enabled = function() return false end
vim.lsp.inlay_hint.enable = function(value, opts) enabled = { value, opts.bufnr } end
mapping(second, " th").callback()
assert(enabled[1] and enabled[2] == second, "Inlay toggle must target the attached buffer")
attach(second)
assert(
    #vim.api.nvim_get_autocmds({ group = "DaltonLspHighlight", buffer = second }) == 4,
    "Repeated attachment must not duplicate highlight handlers"
)
vim.api.nvim_exec_autocmds("LspDetach", { buffer = second, data = { client_id = 1 } })
assert(#vim.api.nvim_get_autocmds({ group = "DaltonLspHighlight", buffer = second }) == 0)
lsp.setup()
assert(#vim.api.nvim_get_autocmds({ group = "DaltonLspNavigation", event = "LspAttach" }) == 1)
print("PASS: navigation, optional features, buffer isolation, highlight cleanup and reload safety")
