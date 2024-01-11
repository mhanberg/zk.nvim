local lsp = vim.lsp

local zk = {}

local get_zk_client = function()
  local clients = lsp.get_clients { name = "zk" }

  return clients[1]
end

local default_callbacks = {
  new = function(err, result)
    if err then
      vim.api.nvim_err_write("[zk] Error creating new note: " .. vim.inspect(err))
      return
    end

    vim.cmd("edit " .. result.path)
  end,
}

local setup = function(opts)
  require("lspconfig").zk.setup(vim.tbl_extend("force", {
    commands = {
      Notes = { require("zk.notes").find },
      Tags = { require("zk.notes").find_by_tag },
      Backlinks = {
        function()
          require("zk.notes").find { linkTo = { vim.fn.expand("%") } }
        end,
      },
      Links = {
        function()
          require("zk.notes").find { linkedBy = { vim.fn.expand("%") } }
        end,
      },
    },
  }, opts))
end

local get = function(file_path, fields)
  local default_fields = { "title", "absPath" }
  local err, result = zk.list { select = fields or default_fields, limit = 1, hrefs = { file_path } }

  return err, result[1]
end

local funcs = {
  get = get,
  setup = setup,
}

setmetatable(zk, {
  __index = function(_, key)
    if funcs[key] then
      return funcs[key]
    else
      return function(args)
        local client = get_zk_client()
        local resp = client.request_sync("workspace/executeCommand", {
          command = "zk." .. key,
          arguments = { vim.api.nvim_buf_get_name(0), args },
        }, nil, 0)

        local err = resp.err
        local result = resp.result

        if default_callbacks[key] then
          return default_callbacks[key](err, result)
        else
          return err, result
        end
      end
    end
  end,
})

return zk
