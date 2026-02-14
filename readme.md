<h1 align=center>AlignEm.nvim</h1>
<p align=center><i>AlignEm.nvim is a simple tool to help you align stuff in your code quickly and easily</i></p>

https://github.com/user-attachments/assets/0bf991aa-7d58-4379-9583-4d85bba467f2

Imagine if nvim-multi-visual and easy-align had a baby and the baby immediately suffered a head injury then that baby would be AlignEm.nvim. 

### How to use
Lazy
```
{ "superNGA/AlignEm.nvim" }
```

Setup
```
local AlignEm = require("AlignEm")
AlignEm.setup()
vim.keymap.set('n', "<Esc>", function() AlignEm.RemoveAllCursors() end) -- to remove cursors
vim.keymap.set('n', "<C-0>", function() AlignEm.AddCursor()        end) -- to add cursors
vim.keymap.set('n', "<C-m>", function() AlignEm.AlignAllCursors()  end) -- Align all cursors
```
Change keybinds
