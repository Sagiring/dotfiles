local keymap = vim.keymap

-- Basic navigation & editing
keymap.set("i", "jj", "<Esc>")
keymap.set("n", "H", "^")
keymap.set("n", "L", "$")

-- Fast save & quit
keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit window" })
keymap.set("n", "<leader><space>", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- Visual mode indentation (keep selection)
keymap.set("v", "<", "<gv", { desc = "Indent left and keep selection" })
keymap.set("v", ">", ">gv", { desc = "Indent right and keep selection" })

-- Move selected lines up and down
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Paste without replacing clipboard register
keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })

-- Nvim-tree & Window navigation
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree (Space+e)" })
keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { desc = "Toggle file tree (Ctrl+n)" })

-- Space + h: 切换回左侧目录树
keymap.set("n", "<leader>h", ":NvimTreeFocus<CR>", { desc = "Focus file tree (Space+h)" })

-- Space + l: 从目录树切换回右侧编辑器
keymap.set("n", "<leader>l", function()
    if vim.bo.filetype == "NvimTree" then
        vim.cmd("wincmd p")
    else
        vim.cmd("wincmd l")
    end
end, { desc = "Focus editor window (Space+l)" })

-- Bufferline
keymap.set("n", "<C-L>", ":BufferLineCycleNext<CR>", { desc = "Next buffer" })
keymap.set("n", "<C-H>", ":BufferLineCyclePrev<CR>", { desc = "Previous buffer" })

-- LSP keymaps
keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP: Go to definition" })
keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: Go to declaration" })
keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP: Hover documentation" })
keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "LSP: Go to implementation" })
keymap.set("n", "gr", vim.lsp.buf.references, { desc = "LSP: Find references" })
keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: Rename symbol" })
keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code action" })
keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, { desc = "LSP: Format code" })

-- Diagnostic keymaps
keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
