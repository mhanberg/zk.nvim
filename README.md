# zk.nvim

A plugin for interacting with the [zk](https://github.com/mickael-menu/zk) language server and fzf-lua.

## Install

### zk

You can install `zk` with Homebrew

```sh
$ brew install zk
```

### vim-plug

```vim
Plug "ibhagwan/fzf-lua"
Plug "neovim/lspconfig"
Plug "mhanberg/zk.nvim"
```

### packer

```lua
use {
  "mhanberg/zk.nvim",
  requires = {
    "ibhagwan/fzf-lua",
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
- `ctrl-e`: create a new note with the current query.

## Lua API

zk.nvim provides the ability to call any of the custom actions provided by the zk language server as well as some higher level commands.

Some of the commands provide default callback and can be found [here](https://github.com/mhanberg/zk.nvim/blob/main/lua/zk/init.lua).

```lua
local zk = require("zk")

-- zk custom actions

zk.new({title = "new note!"})
local err, notes = zk.list({select = {"title", "filename"}})
local err, tags = zk["tag.list"]()

-- zk.nvim provided functions

-- Get a single note by it's file path, can also take a list of fields to return. Defaults to `{"title", "absPath"}`
local err, note = zk.get(file_path)
local err, note = zk.get(file_path, {"title", "tags", "filename"})

-- Initialize zk.nvim, set the Setup section for more info
zk.setup(opts)
```

The commands are powered by the following two Lua functions.

- `require("zk.notes").find(opts)` - takes the options documented [here](https://github.com/mickael-menu/zk/blob/main/docs/editors-integration.md#zklist).
- `require("zk.notes").find_by_tag()`

## Examples

For examples of how to, please see my dotfiles.

- [Setup](https://github.com/mhanberg/.dotfiles/blob/82737f009fb9acb23922ddb8fe63e8e191653d6b/config/nvim/init.lua#L157)
- [zk.get](https://github.com/mhanberg/.dotfiles/blob/82737f009fb9acb23922ddb8fe63e8e191653d6b/config/nvim/plugin/dnd.lua#L6)
- [zk.list](https://github.com/mhanberg/.dotfiles/blob/82737f009fb9acb23922ddb8fe63e8e191653d6b/config/nvim/plugin/dnd.lua#L13)
