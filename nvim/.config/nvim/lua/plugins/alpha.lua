return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local dashboard = require "alpha.themes.dashboard"

    -- 1. HEADER: El arte ASCII exacto de la imagen
    dashboard.section.header.val = {
      [[ /$$$$$$$$ /$$   /$$ /$$$$$$  /$$$$$$  /$$      /$$  /$$$$$$  ]],
      [[| $$_____/| $$$ | $$|_  $$_/ /$$__  $$| $$$    /$$$ /$$__  $$ ]],
      [[| $$      | $$$$| $$  | $$  | $$  \__/| $$$$  /$$$$| $$  \ $$ ]],
      [[| $$$$$   | $$ $$ $$  | $$  | $$ /$$$$| $$ $$/$$ $$| $$$$$$$$ ]],
      [[| $$__/   | $$  $$$$  | $$  | $$|_  $$| $$  $$$| $$| $$__  $$ ]],
      [[| $$      | $$\  $$$  | $$  | $$  \ $$| $$\  $ | $$| $$  | $$ ]],
      [[| $$$$$$$$| $$ \  $$ /$$$$$$|  $$$$$$/| $$ \/  | $$| $$  | $$ ]],
      [[|________/|__/  \__/|______/ \______/ |__/     |__/|__/  |__/ ]],
      [[                                                              ]],
      [[                                                              ]],
      [[                                                              ]],
      [[ /$$   /$$ /$$$$$$$$  /$$$$$$  /$$    /$$ /$$$$$$ /$$      /$$]],
      [[| $$$ | $$| $$_____/ /$$__  $$| $$   | $$|_  $$_/| $$$    /$$$]],
      [[| $$$$| $$| $$      | $$  \ $$| $$   | $$  | $$  | $$$$  /$$$$]],
      [[| $$ $$ $$| $$$$$   | $$  | $$|  $$ / $$/  | $$  | $$ $$/$$ $$]],
      [[| $$  $$$$| $$__/   | $$  | $$ \  $$ $$/   | $$  | $$  $$$| $$]],
      [[| $$\  $$$| $$      | $$  | $$  \  $$$/    | $$  | $$\  $ | $$]],
      [[| $$ \  $$| $$$$$$$$|  $$$$$$/   \  $/    /$$$$$$| $$ \/  | $$]],
      [[|__/  \__/|________/ \______/     \_/    |______/|__/     |__/]],
      [[                                                              ]],
    }

    -- 2. BOTONES: Lista compacta con iconos
    dashboard.section.buttons.val = {
      dashboard.button("e", "  New file", "<cmd>ene <CR>"),
      dashboard.button("SPC f f", "  Find file", "<cmd>Telescope find_files<CR>"),
      dashboard.button("SPC f h", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
      dashboard.button("SPC f r", "  Frecency", "<cmd>Telescope frecency<CR>"),
      dashboard.button("SPC f g", "text  Find word", "<cmd>Telescope live_grep<CR>"),
      dashboard.button("SPC f m", "  Bookmarks", "<cmd>Telescope marks<CR>"),
      dashboard.button("SPC s l", "  Last session", "<cmd>loadsession<CR>"),
      dashboard.button("q", "󰅚  Quit", "<cmd>qa<CR>"),
    }

    -- 3. COLORES "SPACE VOID" (Tu Fondo)
    -- Cian para las estrellas, Rojo para la acción
    local cian_neon = "#00ffff"
    local rojo_nebula = "#ff5555"
    local blanco_estrella = "#ffffff"
    local gris_sutil = "#5e6878"

    local function set_colors()
      -- Header en Cian brillante
      vim.api.nvim_set_hl(0, "AlphaHeader", { fg = cian_neon, bold = true })

      -- Texto de los botones en Blanco/Gris claro
      vim.api.nvim_set_hl(0, "AlphaButtons", { fg = blanco_estrella })

      -- Atajos (SPC f f) en Rojo Nebula
      vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = rojo_nebula, bold = true })

      -- Iconos del dashboard (Opcional: Si quieres que sean cian también)
      vim.api.nvim_set_hl(0, "AlphaIcon", { fg = cian_neon })
    end

    set_colors()

    -- Asignamos los colores
    dashboard.section.header.opts.hl = "AlphaHeader"
    dashboard.section.buttons.opts.hl = "AlphaButtons"
    -- Truco: Esto fuerza que los iconos usen el color definido arriba
    dashboard.section.buttons.opts.hl_shortcut = "AlphaShortcut"

    -- LAYOUT LIMPIO
    dashboard.config.layout = {
      { type = "padding", val = 6 }, -- Más espacio arriba para centrarlo
      dashboard.section.header,
      { type = "padding", val = 3 },
      dashboard.section.buttons,
    }

    require("alpha").setup(dashboard.config)
  end,
}
