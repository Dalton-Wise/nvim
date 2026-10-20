local M = {}

function M.url(remote, sha, path, first, last)
    local repo = remote:match("^git@github%.com:(.+)$")
        or remote:match("^https://github%.com/(.+)$")
        or remote:match("^ssh://git@github%.com/(.+)$")
    if not repo then return nil end
    repo = repo:gsub("%.git$", "")
    path = path:gsub("([^%w%-_%.~/])", function(char) return string.format("%%%02X", string.byte(char)) end)
    first, last = math.min(first, last), math.max(first, last)
    return string.format("https://github.com/%s/blob/%s/%s#L%d-L%d", repo, sha, path, first, last)
end

function M.open(selection)
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then return end
    local cwd = vim.fs.dirname(file)
    local function git(args)
        local command = { "git", "-C", cwd }
        vim.list_extend(command, args)
        local result = vim.system(command, { text = true }):wait()
        return result.code == 0 and vim.trim(result.stdout) or nil
    end
    local root = git({ "rev-parse", "--show-toplevel" })
    local remote = git({ "remote", "get-url", "origin" })
    local sha = git({ "rev-parse", "HEAD" })
    if not root or not remote or not sha then
        vim.notify("No GitHub origin and commit found for this file", vim.log.levels.WARN)
        return
    end
    local first = selection and vim.fn.line("v") or vim.fn.line(".")
    local url = M.url(remote, sha, file:sub(#root + 2), first, vim.fn.line("."))
    if not url then
        vim.notify("Origin is not a supported GitHub remote", vim.log.levels.WARN)
        return
    end
    vim.ui.open(url)
end

return M
