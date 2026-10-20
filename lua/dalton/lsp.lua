local M = {}

function M.setup()
    local group = vim.api.nvim_create_augroup("DaltonLspNavigation", { clear = true })
    local highlights = vim.api.nvim_create_augroup("DaltonLspHighlight", { clear = true })
    vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(event)
            local function map(key, action, description, mode)
                vim.keymap.set(mode or "n", key, action, {
                    buffer = event.buf,
                    desc = "LSP: " .. description,
                    silent = true,
                })
            end
            local function picker(name)
                return function() require("telescope.builtin")[name]() end
            end

            map("gd", picker("lsp_definitions"), "Go to definition")
            map("grd", picker("lsp_definitions"), "Go to definition")
            map("gD", vim.lsp.buf.declaration, "Go to declaration")
            map("grD", vim.lsp.buf.declaration, "Go to declaration")
            map("gi", picker("lsp_implementations"), "Find implementations")
            map("gri", picker("lsp_implementations"), "Find implementations")
            map("gu", picker("lsp_references"), "Find usages")
            map("grr", picker("lsp_references"), "Find references")
            map("grt", picker("lsp_type_definitions"), "Go to type definition")
            map("gO", picker("lsp_document_symbols"), "Search document symbols")
            map("gW", picker("lsp_dynamic_workspace_symbols"), "Search workspace symbols")
            map("<leader>ws", picker("lsp_dynamic_workspace_symbols"), "Search workspace symbols")
            map("gh", vim.lsp.buf.hover, "Documentation")
            map("gH", vim.diagnostic.open_float, "Diagnostic details")
            map("gp", vim.lsp.buf.signature_help, "Parameter information")
            map("grn", vim.lsp.buf.rename, "Rename")
            map("gra", vim.lsp.buf.code_action, "Code action", { "n", "x" })

            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if not client then return end
            if client:supports_method("textDocument/prepareCallHierarchy", event.buf) then
                map("<leader>ci", vim.lsp.buf.incoming_calls, "Incoming calls")
                map("<leader>co", vim.lsp.buf.outgoing_calls, "Outgoing calls")
            end
            if client:supports_method("textDocument/prepareTypeHierarchy", event.buf) then
                map("<leader>ts", function() vim.lsp.buf.typehierarchy("subtypes") end, "Subtypes")
                map("<leader>tu", function() vim.lsp.buf.typehierarchy("supertypes") end, "Supertypes")
            end
            if client:supports_method("textDocument/inlayHint", event.buf) then
                map(
                    "<leader>th",
                    function()
                        vim.lsp.inlay_hint.enable(
                            not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }),
                            { bufnr = event.buf }
                        )
                    end,
                    "Toggle inlay hints"
                )
            end
            if client:supports_method("textDocument/documentHighlight", event.buf) then
                vim.api.nvim_clear_autocmds({ group = highlights, buffer = event.buf })
                vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                    group = highlights,
                    buffer = event.buf,
                    callback = vim.lsp.buf.document_highlight,
                })
                vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                    group = highlights,
                    buffer = event.buf,
                    callback = vim.lsp.buf.clear_references,
                })
            end
        end,
    })
    vim.api.nvim_create_autocmd("LspDetach", {
        group = group,
        callback = function(event)
            vim.api.nvim_clear_autocmds({ group = highlights, buffer = event.buf })
            vim.api.nvim_buf_call(event.buf, vim.lsp.buf.clear_references)
        end,
    })
    vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        virtual_text = { source = "if_many", spacing = 2 },
        underline = { severity = vim.diagnostic.severity.ERROR },
    })
end

return M
