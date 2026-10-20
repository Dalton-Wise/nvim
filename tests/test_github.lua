-- Run with: nvim --headless -u NONE -i NONE -l tests/test_github.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local github = dofile(root .. "/lua/dalton/github.lua")
local expected = "https://github.com/example/service/blob/abc123/src/A%20%231.java#L3-L8"
for _, remote in ipairs({
    "git@github.com:example/service.git",
    "https://github.com/example/service.git",
    "ssh://git@github.com/example/service.git",
}) do
    assert(github.url(remote, "abc123", "src/A #1.java", 8, 3) == expected)
end
assert(github.url("git@example.com:org/repo.git", "abc", "File.java", 1, 1) == nil)
print("PASS: GitHub remote parsing, URL encoding and reversed selections")
