vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Browse directory (netrw)" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic list" })
vim.keymap.set("n", "]e", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
vim.keymap.set(
    "n",
    "[e",
    function() vim.diagnostic.jump({ count = -1, float = true }) end,
    { desc = "Previous diagnostic" }
)

vim.keymap.set("n", "<C-v>", "<cmd>vsplit<CR>", { desc = "Split vertically" })
vim.keymap.set("n", "<C-s>", "<cmd>split<CR>", { desc = "Split horizontally" })
vim.keymap.set("n", "<C-c>", "<cmd>close<CR>", { desc = "Close window" })
for key, direction in pairs({ h = "h", j = "j", k = "k", l = "l" }) do
    vim.keymap.set("n", "<C-" .. key .. ">", "<C-w>" .. direction, { desc = "Focus window " .. direction })
end
vim.keymap.set("n", "<leader>z", function() require("dalton.zoom").toggle() end, { desc = "Toggle window zoom" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "gB", function() require("dalton.github").open(false) end, { desc = "Open line on GitHub" })
vim.keymap.set("x", "gB", function() require("dalton.github").open(true) end, { desc = "Open selection on GitHub" })
vim.keymap.set("n", "<leader>gr", function() require("dalton.tuicr").open() end, { desc = "Review changes (tuicr)" })
