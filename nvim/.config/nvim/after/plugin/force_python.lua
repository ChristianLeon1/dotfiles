-- Esto se ejecuta AL FINAL, sobrescribiendo a NvChad
vim.g.loaded_python3_provider = nil -- Reactivar (borrar el bloqueo)
vim.g.python3_host_prog = '/usr/bin/python3' -- Forzar ruta Fedora
