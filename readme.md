<h1 align=center>AlignEm.nvim</h1>

<p align="center">
  <i>A lightweight Neovim plugin for quickly aligning code using multiple cursors</i>
</p>

https://github.com/user-attachments/assets/98634c50-8011-4a8a-96a9-c1d132c1efcf

AlignEm.nvim provides a simple way to place multiple cursors and align text across lines, inspired by the convenience of multiple-cursor selections and easy-align functionality.

### How to use
Lazy
```
{ "superNGA/AlignEm.nvim" }
```

Setup
```
local AlignEm = require("AlignEm")

AlignEm.setup()

-- Recommended keymaps
vim.keymap.set("n", "<Esc>", AlignEm.RemoveAllCursors, { desc = "AlignEm: Remove all cursors" })
vim.keymap.set("n", "<C-0>", AlignEm.AddCursor,        { desc = "AlignEm: Add cursor" })
vim.keymap.set("n", "<C-m>", AlignEm.AlignAllCursors,  { desc = "AlignEm: Align all cursors" })
```

### Usage

- Switch to Normal mode
- Place the cursor on the desired line and press <C-0> to add an alignment cursor.
- Use normal Noevim motions to move all plugins at once.
- Press <C-m> to align all marked cursors.
- Press <Esc> to clear all alignment cursors when finished.
