local zk = require("zk")
local fzf = require("fzf-lua").fzf_exec
local ansi = require("zk.ansicolors")

local delimiter = "\x01 "
local builtin = require("fzf-lua.previewer.builtin")

-- Inherit from the "buffer_or_file" previewer
local MyPreviewer = builtin.buffer_or_file:extend()

function MyPreviewer:new(o, opts, fzf_win)
  MyPreviewer.super.new(self, o, opts, fzf_win)
  setmetatable(self, MyPreviewer)
  return self
end

function MyPreviewer:parse_entry(entry_str)
  -- Assume an arbitrary entry in the format of 'file:line'
  local splat = vim.fn.split(entry_str, delimiter)
  return {
    path = splat[3],
  }
end

local notes = {}

local prepend_hash = function(str)
  return "#" .. str
end

local default_opts = function(opts)
  return vim.tbl_extend(
    "force",
    { select = { "title", "tags", "absPath" }, sort = { "created" } },
    opts or {}
  )
end

local options = {
  ["--print-query"] = "",
  ["--ansi"] = "",
  ["--header"] = ansi("'%{blue}CTRL-E: create a note with the query as title'"),
  ["--delimiter"] = delimiter,
  ["--nth"] = "1..2",
}

local to_note_entry = function(n)
  local sep = " "
  local tags = vim.fn.join(vim.tbl_map(prepend_hash, n.tags or {}), sep)

  return ansi("%{bright}%{yellow}" .. (n.title or ""))
    .. delimiter
    .. ansi("%{red}" .. tags)
    .. ansi("%{italic}%{dim}" .. delimiter .. n.absPath)
end

notes.find = function(...)
  local err, result = zk.list(default_opts(...))
  if err then
    vim.api.nvim_err_write("[zk] Error fetching notes: " .. vim.inspect(err))

    return
  end

  if #result == 0 then
    vim.api.nvim_err_writeln("[zk] No notes found!")

    return
  end

  fzf(vim.tbl_map(to_note_entry, result), {
    actions = {
      ["enter"] = function(selected)
        local parts = vim.fn.split(selected[1], delimiter)
        local picked = parts[#parts]
        vim.fn.execute("edit " .. picked)
      end,
      ["ctrl-v"] = function(selected)
        local parts = vim.fn.split(selected[1], delimiter)
        local picked = parts[#parts]
        vim.fn.execute("vsplit " .. picked)
      end,
      ["ctrl-x"] = function(selected)
        local parts = vim.fn.split(selected[1], delimiter)
        local picked = parts[#parts]
        vim.fn.execute("split " .. picked)
      end,
      ["ctrl-e"] = function()
        local query = require("fzf-lua").config.__resume_data.last_query
        zk.new { title = query }
      end,
    },
    prompt = "Notes> ",
    fzf_opts = options,
    win_opts = { width = 0.9, height = 0.6, row = 0 },
    previewer = MyPreviewer,
  })
end

notes.find_by_tag = function()
  local err, result = zk["tag.list"](nil)
  if err then
    vim.api.nvim_err_write("[zk] Error fetching tags: " .. vim.inspect(err))
    return
  end

  local tags = vim.tbl_map(function(t)
    return t.name
  end, result)

  fzf(tags, {
    actions = {
      ["enter"] = function(selected)
        notes.find { tags = { selected[1] } }
      end,
    },
    prompt = "Tags> ",
    fzf_opts = options,
    win_opts = { width = 0.9, height = 0.6, row = 0 },
  })
end

return notes
