return {
    "JetBrains/intellij-lsp.nvim",
    commit = "9cfad18005470e4187090013e08f92ec9e437219",
    lazy = false,
    opts = function()
        -- INTELLIJ_LSP_SERVER can point at a newer bundle when an EAP build expires.
        -- Use the verified local bundle, avoiding the upstream 0.11 downloader issue.
        local server = vim.env.INTELLIJ_LSP_SERVER
        if not server or server == "" then
            server = vim.fn.stdpath("data") .. "/intellij-lsp/server/263.6379.0/bin/intellij-server"
        end
        local sdk = vim.env.JAVA_HOME
        if not sdk or sdk == "" then
            local result = vim.system({ "/usr/libexec/java_home", "-v", "21" }, { text = true }):wait()
            sdk = result.code == 0 and vim.trim(result.stdout) or nil
        end
        return {
            accept_eula = true,
            server_path = server,
            default_sdk = sdk,
            -- Blink, Telescope and our LspAttach handler own the editor UI.
            autotrigger = false,
            word_triggers = false,
            completeopt = false,
            enter_accepts_completion = false,
            references = false,
            keymaps = false,
            inlay_hints = false,
            folding = false,
            document_highlight = false,
            signature_help = false,
            file_templates = false,
            single_key_select = false,
            colorscheme = false,
            format_on_save = false,
            git = false,
            run = false,
            debug = false,
        }
    end,
}
