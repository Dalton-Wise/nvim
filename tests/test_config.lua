-- Run with: nvim --headless -u NONE -i NONE -l tests/test_config.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local function spec(name) return dofile(root .. "/lua/dalton/lazy/" .. name .. ".lua") end

local setup_calls = 0
local mason
local configs = {}
local disabled
package.loaded["dalton.lsp"] = { setup = function() setup_calls = setup_calls + 1 end }
package.loaded["blink.cmp"] = { get_lsp_capabilities = function() return { testCompletion = true } end }
package.loaded["mason-tool-installer"] = { setup = function() end }
package.loaded["mason-lspconfig"] = { setup = function(opts) mason = opts end }
vim.lsp.config = function(name, opts) configs[name] = vim.tbl_deep_extend("force", configs[name] or {}, opts) end
vim.lsp.enable = function(name, value) disabled = { name, value } end
spec("lsp").config()
assert(setup_calls == 1)
assert(vim.deep_equal(mason.ensure_installed, { "lua_ls", "pylsp", "gopls" }))
assert(vim.deep_equal(mason.automatic_enable, mason.ensure_installed), "Only non-Java servers may auto-start")
assert(disabled[1] == "jdtls" and disabled[2] == false)
for _, name in ipairs(mason.ensure_installed) do
    assert(configs[name].capabilities.testCompletion)
end

local intellij = spec("intellij")
assert(intellij.lazy == false, "IntelliJ must load at startup for eager project import")
vim.env.JAVA_HOME = "/jdk with spaces"
vim.env.INTELLIJ_LSP_SERVER = "/custom bundle/bin/intellij-server"
local opts = intellij.opts()
assert(opts.accept_eula and opts.default_sdk == "/jdk with spaces")
assert(opts.server_path == vim.env.INTELLIJ_LSP_SERVER)
for _, key in ipairs({
    "colorscheme",
    "autotrigger",
    "word_triggers",
    "completeopt",
    "enter_accepts_completion",
    "references",
    "keymaps",
    "document_highlight",
    "signature_help",
    "single_key_select",
    "format_on_save",
}) do
    assert(opts[key] == false, "IntelliJ must not take over " .. key)
end
vim.env.JAVA_HOME = nil
vim.env.INTELLIJ_LSP_SERVER = nil
vim.system = function(command)
    assert(vim.deep_equal(command, { "/usr/libexec/java_home", "-v", "21" }))
    return { wait = function() return { code = 0, stdout = "/detected/jdk\n" } end }
end
assert(intellij.opts().default_sdk == "/detected/jdk")
vim.env.INTELLIJ_LSP_SERVER = ""
assert(
    intellij.opts().server_path:match("/263%.6379%.0/bin/intellij%-server$"),
    "An empty override must use the installed bundle"
)
vim.system = function()
    return { wait = function() return { code = 1 } end }
end
assert(intellij.opts().default_sdk == nil, "Missing fallback JDK must not become an invalid path")

local expanded
package.loaded["telescope.themes"] = { get_dropdown = function() return {} end }
package.loaded["telescope.builtin"] = { live_grep = function() expanded = "grep" end }
local telescope = spec("telescope")
local telescope_opts = telescope.opts()
assert(telescope_opts.defaults.path_display[1] == "filename_first")
local keys = {}
for _, key in ipairs(telescope.keys) do
    keys[key[1]] = key
end
assert(keys["<leader>sf"] and keys["<leader>sg"] and keys["<leader><leader>"])
assert(not keys["<leader>f"] and not keys["<leader>g"], "Search prefixes must not shadow format/git")
keys["<leader>sg"][2]()
assert(expanded == "grep")
for _, name in ipairs({ "binary.java", "src/binding/Foo.java", "src/building/Foo.java" }) do
    for _, pattern in ipairs(telescope_opts.defaults.file_ignore_patterns) do
        assert(not name:match(pattern), "Build exclusions must not hide " .. name)
    end
end
for _, name in ipairs({ "build/Foo.class", "module/build/Foo.class", "bin/Foo.class", "module/bin/Foo.class" }) do
    local ignored = false
    for _, pattern in ipairs(telescope_opts.defaults.file_ignore_patterns) do
        ignored = ignored or name:match(pattern)
    end
    assert(ignored, "Output directory was not excluded: " .. name)
end

local format = spec("format").opts.format_on_save
vim.bo.filetype = "java"
assert(format(0) == nil, "Java must not be reformatted automatically")
vim.bo.filetype = "kotlin"
assert(format(0) == nil)
vim.bo.filetype = "lua"
assert(format(0).lsp_format == "fallback")
assert(spec("blink").opts.snippets.preset == "luasnip")
print("PASS: IntelliJ ownership, SDK resolution, themes, server isolation, search keys and formatting policy")
