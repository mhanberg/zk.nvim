# zk.nvim

A plugin for interacting with the [zk](https://github.com/mickael-menu/zk) language server and fzf.

This is an exploratory plugin, mostly made for sharing the code for other to try.

## Install

### vim-plug

```vim
Plug "junegunn/fzf"
Plug "junegunn/fzf.vim"
Plug "neovim/lspconfig"
Plug "mhanberg/zk.nvim"
```

### packer

```lua
use {
  "mhanberg/zk.nvim",
  requires = {
    "junegunn/fzf",
    "junegunn/fzf.vim",
    "neovim/lspconfig"
  }
}
```

## Setup

```lua
-- take the same options as `require("lspconfig").zk.setup`
require("zk").setup({
  on_attach = function(client, bufnr)
      -- attach keymaps here
      local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
      end
      local opts = { noremap = true, silent = true }

      buf_set_keymap("n", "<C-p>", [[:Notes<cr>]], opts)
      buf_set_keymap("n", "<space>zt", [[:Tags<cr>]], opts)
      buf_set_keymap("n", "<space>zl", [[:Links<cr>]], opts)
      buf_set_keymap("n", "<space>zb", [[:Backlinks<cr>]], opts)

      -- follow the link under the cursor
      buf_set_keymap("n", "dt", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
      -- show preview of note under the cursor 
      buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
      -- create a new note from the current visual selection and insert a link to it.
      buf_set_keymap("v", "<leader>zn", ":'<,'>lua vim.lsp.buf.range_code_action()<cr>", opts)

      -- remember to initialize your completion plugin if necessary
      -- require("cmp_nvim_lsp").update_capabilities(capabilities)
  end})
```

## Commands

- `:Notes` - fzf all of your notes
- `:Tags` - fzf all of your tags, then fzf notes from the selected tag
- `:Links` - fzf notes linked by the current buffer
- `:Backlinks` -fzf notes linking to the current buffer

When fzfing over notes, you can use the following keybinds

- `enter`: open note in current window.
- `ctrl-v`: open note in a vertical split.
- `ctrl-x`: open note in a horizontal split.
- `ctrl-t`: open note in a new tab page.

## Lua API

zk.nvim provides the ability to call any of the custom actions provided by the zk language server with the results executed by a callback.

Some of the commands provide default callback and can be found [here](https://github.com/mhanberg/zk.nvim/blob/main/lua/zk/init.lua).

```lua
local zk = require("zk")

zk.new({title = "new note!"})

zk.list({select = {"title", "filename"}}, function(err, notes)
  print(vim.inspect(notes))
end)

zk["tag.list"](nil, function(err, tags)
  print(vim.inspect(tags))
end)
```

The commands are powered by the following two lua functions.

- `require("zk.notes").find(opts)` - takes the options documented [here](https://github.com/mickael-menu/zk/blob/main/docs/editors-integration.md#zklist).
- `require("zk.notes").find_by_tag()`

### FZF

This plugin also provides a lua helper function for calling fzf. This is done by creating a vimscript wrapper function for `fzf#run(fzf#wrap(opts))`. Please see the fzf documentation for more information.

```lua
local fzf = require("zk.fzf")

fzf({
  source = {"list", "of", "entries",
  sinklist = function(selected)
    -- the lua vimscript wrapper allows us to use a lua function as the sink or sinklist.o

    print(selected)
  end,
  options = options,
  window = { width = 0.9, height = 0.6, yoffset = 0, highlight = "Normal" },
})
```
