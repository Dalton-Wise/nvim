-- Preserved JDTLS configuration; not imported by lazy.nvim.
return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        { "j-hui/fidget.nvim", version = "*", opts = {} },
    },

    config = function()
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("DaltonLspNavigation", { clear = true }),
            callback = function(event)
                local function map(key, action, description)
                    vim.keymap.set("n", key, action, {
                        buffer = event.buf,
                        desc = "LSP: " .. description,
                        silent = true,
                    })
                end
                local function telescope(picker)
                    return function()
                        require("telescope.builtin")[picker]()
                    end
                end

                map("gd", telescope("lsp_definitions"), "Go to definition")
                map("gD", vim.lsp.buf.declaration, "Go to declaration")
                map("gri", telescope("lsp_implementations"), "Find implementations")
                map("grr", telescope("lsp_references"), "Find references")
                map("grt", telescope("lsp_type_definitions"), "Go to type definition")
                map("gO", telescope("lsp_document_symbols"), "Search document symbols")
                map("<leader>ws", telescope("lsp_dynamic_workspace_symbols"), "Search workspace symbols")
            end,
        })

        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())
        local servers = { "lua_ls", "pylsp", "gopls", "jdtls" }

        require("mason-lspconfig").setup({
            ensure_installed = servers,
            handlers = {
                function(server_name)
                    if vim.tbl_contains(servers, server_name) then
                        require("lspconfig")[server_name].setup {
                            capabilities = capabilities
                        }
                    end
                end,

                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                runtime = { version = "Lua 5.1" },
                                diagnostics = {
                                    globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,

                ["jdtls"] = function()
                    local gradle_init = vim.fn.stdpath("config") .. "/gradle/jdtls.init.gradle"
                    local lombok = vim.fn.stdpath("data") .. "/mason/packages/jdtls/lombok.jar"
                    local settings = {
                        java = {
                            autobuild = { enabled = true },
                            import = {
                                gradle = {
                                    arguments = {
                                        "--init-script",
                                        gradle_init,
                                    },
                                },
                            },
                        },
                    }
                    require("lspconfig").jdtls.setup {
                        capabilities = capabilities,
                        settings = settings,
                        init_options = { settings = settings },
                        handlers = {
                            ["language/status"] = function(err, result, ctx)
                                local fidget = require("fidget")
                                if err then
                                    fidget.notify(err.message or tostring(err), vim.log.levels.ERROR, {
                                        annote = "Java",
                                        ttl = 10,
                                    })
                                    return
                                end
                                if not result or not result.message then
                                    return
                                end

                                local is_error = result.type == "Error"
                                fidget.notify(result.message, is_error and vim.log.levels.ERROR or vim.log.levels.INFO, {
                                    key = not is_error and ("jdtls-status-" .. ctx.client_id) or nil,
                                    annote = "Java",
                                    ttl = is_error and 10 or 3,
                                })
                            end,
                        },
                        on_new_config = function(config, root_dir)
                            -- A changed output policy must not reuse an old Gradle project model.
                            local policy = vim.fn.sha256(table.concat(vim.fn.readfile(gradle_init), "\n")):sub(1, 12)
                            local workspace = vim.fn.stdpath("cache") .. "/jdtls/"
                                .. vim.fn.sha256(root_dir or vim.fn.getcwd()) .. "-" .. policy
                            for index, arg in ipairs(config.cmd) do
                                if arg == "-data" then
                                    config.cmd[index + 1] = workspace
                                    break
                                end
                            end
                            config.init_options.workspace = workspace

                            local metadata_arg = "--jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false"
                            if not vim.tbl_contains(config.cmd, metadata_arg) then
                                table.insert(config.cmd, metadata_arg)
                            end

                            if vim.fn.filereadable(lombok) == 1 then
                                local agent_arg = "--jvm-arg=-javaagent:" .. lombok
                                if not vim.tbl_contains(config.cmd, agent_arg) then
                                    table.insert(config.cmd, agent_arg)
                                end
                            else
                                vim.notify("JDTLS Lombok agent missing: " .. lombok .. ". Reinstall jdtls with :Mason.",
                                    vim.log.levels.WARN)
                            end
                        end,
                    }
                end
            }
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = true,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
