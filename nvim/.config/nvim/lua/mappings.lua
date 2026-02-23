require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("n", "<leader>co", "<cmd> VimtexCompile <cr>")
map("i", "jk", "<ESC>")

-- Mapeo para ejecutar Python con <Leader> + r (Espacio + r)
map("n", "<leader>r", function()
  -- Guarda el archivo antes de ejecutar
  vim.cmd "w"
  
  -- Abre una terminal abajo y corre python3 con el archivo actual
  vim.cmd("sp | term python3 " .. vim.fn.expand("%"))
  
  -- Opción alternativa: Usar la terminal flotante de NvChad
  -- require("nvchad.term").runner {
  --   cmd = "python3 " .. vim.fn.expand("%"),
  --   id = "python_runner",
  --   title = "Python Output",
  -- }
end, { desc = "Ejecutar Python" })

-- Debugger
map("n", "<leader>db", "<cmd> DapToggleBreakpoint <CR>", { desc = "Toggle Breakpoint" })
map("n", "<leader>dr", "<cmd> DapContinue <CR>", { desc = "Start/Continue Debug" })
map("n", "<F10>", "<cmd> DapStepOver <CR>", { desc = "Step Over" })
map("n", "<F11>", "<cmd> DapStepInto <CR>", { desc = "Step Into" })
map("n", "<F12>", "<cmd> DapStepOut <CR>", { desc = "Step Out" }) 

-- Jupyter / Molten
map("n", "<leader>mi", ":MoltenInit<CR>", { desc = "Inicializar Molten" })
map("n", "<leader>mr", ":MoltenEvaluateOperator<CR>", { desc = "Correr selección" })
map("n", "<leader>rr", ":MoltenEvaluateLine<CR>", { desc = "Correr línea" })
map("n", "<leader>rc", ":MoltenReevaluateCell<CR>", { desc = "Re-correr celda" })
map("n", "<leader>rd", ":MoltenDelete<CR>", { desc = "Borrar celda output" })
