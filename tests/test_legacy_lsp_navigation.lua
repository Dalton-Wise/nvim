-- Run with: nvim --headless -u NONE -i NONE -l tests/test_legacy_lsp_navigation.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.g.mapleader = " "

package.loaded["cmp_nvim_lsp"] = { default_capabilities = function() return {} end }
package.loaded["mason-lspconfig"] = { setup = function() end }

local calls = {}
local telescope_loads = 0
local expected = {
    gd = "lsp_definitions",
    gri = "lsp_implementations",
    grr = "lsp_references",
    grt = "lsp_type_definitions",
    gO = "lsp_document_symbols",
    [" ws"] = "lsp_dynamic_workspace_symbols",
}
package.preload["telescope.builtin"] = function()
    telescope_loads = telescope_loads + 1
    local builtins = {}
    for _, picker in pairs(expected) do
        builtins[picker] = function() table.insert(calls, picker) end
    end
    return builtins
end

local declaration_calls = 0
vim.lsp.buf.declaration = function() declaration_calls = declaration_calls + 1 end
local grep = function() end
vim.keymap.set("n", "<leader>g", grep)
local rename = vim.fn.maparg("grn", "n", false, true)
local actions = vim.fn.maparg("gra", "n", false, true)

local function mapping(buffer, key)
    return vim.api.nvim_buf_call(buffer, function()
        return vim.fn.maparg(key, "n", false, true)
    end)
end

local spec = dofile(root .. "/lua/dalton/legacy/jdtls.lua")
spec.config()
assert(telescope_loads == 0, "LSP setup must not load Telescope")
local first = vim.api.nvim_create_buf(true, false)
local second = vim.api.nvim_create_buf(true, false)
for key in pairs(expected) do
    assert(mapping(first, key).buffer ~= 1, "Navigation mapping exists before LSP attachment")
end

vim.api.nvim_exec_autocmds("LspAttach", { buffer = first, data = { client_id = 99 } })
assert(telescope_loads == 0, "LSP attachment must not load Telescope")
local declaration = mapping(first, "gD")
assert(declaration.buffer == 1 and type(declaration.callback) == "function", "Missing buffer-local declaration mapping")
declaration.callback()
assert(declaration_calls == 1 and telescope_loads == 0)
for key, picker in pairs(expected) do
    local bound = mapping(first, key)
    assert(bound.buffer == 1 and type(bound.callback) == "function", "Missing buffer-local mapping: " .. key)
    assert(bound.desc and #bound.desc > 0, "Missing navigation description: " .. key)
    bound.callback()
    assert(calls[#calls] == picker, "Wrong Telescope picker for " .. key)
    assert(mapping(second, key).buffer ~= 1, "Navigation leaked into an unattached buffer")
end
assert(telescope_loads == 1, "Telescope must load only on first use")

vim.api.nvim_exec_autocmds("LspAttach", { buffer = second, data = { client_id = 100 } })
for key in pairs(expected) do
    assert(mapping(second, key).buffer == 1, "Navigation missing from second LSP buffer")
end
assert(mapping(first, " g").callback == grep, "Existing live-grep shortcut changed")
assert(mapping(first, "grn").callback == rename.callback, "Built-in rename mapping changed")
assert(mapping(first, "gra").callback == actions.callback, "Built-in code-action mapping changed")

spec.config()
assert(#vim.api.nvim_get_autocmds({ group = "DaltonLspNavigation", event = "LspAttach" }) == 1,
    "Reloading configuration must not duplicate the navigation autocmd")
print("PASS: buffer-local navigation, correct pickers, on-demand Telescope loading, preserved defaults, and reload safety")
