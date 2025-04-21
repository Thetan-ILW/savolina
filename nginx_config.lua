---@class web.NginxConfig
local config = {
	listen = 8080,
	lua_code_cache = "off",
	client_max_body_size = "10M",
	handler = "svn.app.handler",
	proxied = false,
	package_path = { "3rd-deps/lua" },
	package_cpath = {},
	require = {
		"socket",
		"ltn12",
		"mime",
	},
}

return config
