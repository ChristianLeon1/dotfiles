local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    html = { "prettier" },
    tex = { "latexindent" },
    -- Agregamos Python: primero ordena imports (isort), luego formatea (black)
    python = { "isort", "black" },
  },

  -- Recomendado: Activar formato al guardar para Python
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
