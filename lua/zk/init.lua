local zk = {}

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
					require("zk.notes").find({ linkTo = { vim.fn.expand("%") } })
				end,
			},
			Links = {
				function()
					require("zk.notes").find({ linkedBy = { vim.fn.expand("%") } })
				end,
			},
		},
	}, opts))
end

setmetatable(zk, {
	__index = function(_, key)
		if key == "setup" then
			return setup
		else
			return function(args, callback)
				vim.lsp.buf_request(0, "workspace/executeCommand", {
					command = "zk." .. key,
					arguments = { vim.api.nvim_buf_get_name(0), args },
				}, callback or default_callbacks[key])
			end
		end
	end,
})

return zk
