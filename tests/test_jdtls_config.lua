-- Run with: nvim --headless -u NONE -i NONE -l tests/test_jdtls_config.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local mason_options
local java_options
local policy = "output-policy-v1"
local notifications = {}
local warnings = {}
local lombok_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls/lombok.jar"
local lombok_available = true

package.loaded["cmp_nvim_lsp"] = { default_capabilities = function() return {} end }
package.loaded["mason-lspconfig"] = {
    setup = function(options) mason_options = options end,
}
package.loaded.lspconfig = {
    jdtls = { setup = function(options) java_options = options end },
}
package.loaded.fidget = {
    notify = function(message, level, options)
        table.insert(notifications, { message = message, level = level, options = options })
    end,
}

local spec = dofile(root .. "/lua/dalton/legacy/jdtls.lua")
assert(vim.deep_equal(spec.event, { "BufReadPre", "BufNewFile" }))
spec.config()
assert(vim.deep_equal(mason_options.ensure_installed, { "lua_ls", "pylsp", "gopls", "jdtls" }))
mason_options.handlers[1]("rust_analyzer")
mason_options.handlers[1]("clangd")
mason_options.handlers.jdtls()

local arguments = java_options.settings.java.import.gradle.arguments
assert(arguments[1] == "--init-script" and arguments[2]:match("/gradle/jdtls%.init%.gradle$"))
assert(vim.deep_equal(arguments, java_options.init_options.settings.java.import.gradle.arguments))
assert(java_options.settings.java.autobuild.enabled)

vim.fn.readfile = function(path)
    assert(path == arguments[2])
    return { policy }
end
vim.fn.filereadable = function(path)
    assert(path == lombok_path)
    return lombok_available and 1 or 0
end
vim.notify = function(message, level)
    table.insert(warnings, { message = message, level = level })
end

local function configure(project)
    local config = vim.deepcopy(java_options)
    config.cmd = { "jdtls", "-data", "/old/workspace" }
    config.on_new_config(config, project)
    assert(config.cmd[3] == config.init_options.workspace)
    config.on_new_config(config, project)
    local flags = vim.tbl_filter(function(arg)
        return arg == "--jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false"
    end, config.cmd)
    assert(#flags == 1)
    local agents = vim.tbl_filter(function(arg)
        return arg == "--jvm-arg=-javaagent:" .. lombok_path
    end, config.cmd)
    assert(#agents == 1, "JDTLS must load exactly one Lombok Java agent")
    return config.init_options.workspace
end

local first = configure("/projects/one")
assert(configure("/projects/one") == first, "Unchanged output policy must reuse its cache")
assert(configure("/projects/two") ~= first, "Different projects must not share a workspace")
policy = "output-policy-v2"
assert(configure("/projects/one") ~= first, "Changed output policy must invalidate the old model")
assert(#warnings == 0)

lombok_available = false
local missing_agent = vim.deepcopy(java_options)
missing_agent.cmd = { "jdtls", "-data", "/old/workspace" }
missing_agent.on_new_config(missing_agent, "/projects/no-agent")
assert(not vim.tbl_contains(missing_agent.cmd, "--jvm-arg=-javaagent:" .. lombok_path))
assert(#warnings == 1 and warnings[1].level == vim.log.levels.WARN)
assert(warnings[1].message:find("Lombok", 1, true))

local handler = java_options.handlers["language/status"]
handler(nil, { type = "Starting", message = "70% Downloading dependencies" }, { client_id = 42 })
handler(nil, { type = "Started", message = "Ready" }, { client_id = 42 })
assert(notifications[1].options.key == notifications[2].options.key)
handler(nil, { type = "Error", message = "Import failed" }, { client_id = 42 })
assert(notifications[3].level == vim.log.levels.ERROR and notifications[3].options.key == nil)
handler({ message = "RPC failed" }, nil, { client_id = 42 })
assert(notifications[4].message == "RPC failed" and notifications[4].level == vim.log.levels.ERROR)
handler(nil, nil, { client_id = 42 })
assert(#notifications == 4)

print("PASS: lazy events, servers, Gradle settings, cache migration, metadata, Lombok agent/missing-agent warning, and progress/errors")
