local nvlsp = require "nvchad.configs.lspconfig"

-- Carga la configuración por defecto de NvChad
nvlsp.defaults()

-- Lista de servidores (incluyendo texlab para LaTeX)
local servers = { "html", "cssls", "texlab", "pyright" }

for _, server in ipairs(servers) do
  vim.lsp.config(server, {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  })
  vim.lsp.enable(server)
end
