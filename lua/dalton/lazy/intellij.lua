return {
    "JetBrains/intellij-lsp.nvim",
    lazy = false,
    opts = function()
        -- Unset, the plugin downloads and verifies the server bundle its release pins.
        -- INTELLIJ_LSP_SERVER points at a custom bin/intellij-server instead.
        local server = vim.env.INTELLIJ_LSP_SERVER
        if server == "" then
            server = nil
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
