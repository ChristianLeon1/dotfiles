vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
-- 1. Anular cualquier orden previa de desactivar Python
vim.g.loaded_python3_provider = nil 

-- 2. Forzar la ruta de Python (Fedora)
vim.g.python3_host_prog = '/usr/bin/python3'-- bootstrap lazy and all plugins
vim.g.loaded_remote_plugins = nil
vim.g.loaded_rplugin_vim = nil

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)

-- Autocomando para archivos LaTeX
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex", -- Se activa solo en archivos .tex
  callback = function()
    -- Activa la corrección ortográfica
    vim.opt_local.spell = true
    -- Define los idiomas: inglés y español
    vim.opt_local.spelllang = { "en", "es" }
  end,
})

-- ==========================================
--  Gestor de Templates (Adaptado)
-- ==========================================

-- 1. TUS VARIABLES
local template_name = "Ramírez León Christian Yael" -- Tu nombre aquí
local template_dir = vim.fn.stdpath("config") .. "/templates/" -- Ruta: ~/.config/nvim/templates/

-- 2. Grupo de autocomandos
local augroup = vim.api.nvim_create_augroup("PlantillasAutomaticas", { clear = true })

-- 3. Lógica de inserción y reemplazo
vim.api.nvim_create_autocmd("BufNewFile", {
  group = augroup,
  pattern = "*.*", -- Se activa para cualquier extensión que tenga un .tpl correspondiente
  callback = function()
    local ext = vim.fn.expand("%:e")
    local tpl_file = template_dir .. ext .. ".tpl"

    if vim.fn.filereadable(tpl_file) == 1 then
      -- Insertar contenido
      vim.cmd("0r " .. tpl_file)

      -- Reemplazos automáticos
      local year = os.date("%Y")
      vim.cmd(string.format("silent! %%s/{{YEAR}}/%s/ge", year))
      vim.cmd(string.format("silent! %%s/{{NAME}}/%s/ge", template_name))
      
      -- Limpieza final (borrar líneas vacías extra al final si las hay y volver arriba)
      vim.cmd("normal! G") 
      -- Opcional: Si quieres que el cursor vaya a una posición específica, podrías añadir una marca en el tpl
      vim.cmd("normal! gg")
    end
  end,
})
