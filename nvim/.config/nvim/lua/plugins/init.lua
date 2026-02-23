return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- 1. Configuración del LSP (Servidor de lenguaje)
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- 2. El Plugin Principal: VimTeX
  {
    "lervag/vimtex",
    lazy = false, -- Cargamos al inicio para que detecte los archivos .tex
    init = function()
      -- Opciones básicas de VimTeX
      -- El visualizador depende de tu sistema operativo.
      -- Si usas Linux, 'zathura' es el mejor. Si no, usa 'general'.
      -- vim.g.vimtex_view_method = "zathura"

      -- Configuración opcional para que la compilación sea silenciosa
      vim.g.vimtex_quickfix_mode = 0
    end,
  },

  -- 3. Resaltado de Sintaxis (Treesitter)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "latex",
        "bibtex", -- <-- Agregamos latex y bibtex
      },
      highlight = {
        enable = true,
      },
    },
  },

  {
    "L3MON4D3/LuaSnip",
    -- follow latest changes.
    version = "v2.*",
    -- install jsregexp (optional!).
    build = "make install_jsregexp",

    dependencies = { "rafamadriz/friendly-snippets" },

    config = function(_, opts)
      -- 1. Cargar configuración por defecto
      require("luasnip").setup(opts)

      -- 2. Cargar VSCode snippets (los que trae NvChad por defecto)
      require("luasnip.loaders.from_vscode").lazy_load()

      -- 3. Cargar TUS snippets (formato snipmate)
      require("luasnip.loaders.from_snipmate").lazy_load()
    end,
  },

  {
    "github/copilot.vim",
    lazy = false, -- Cargamos al inicio para que empiece a trabajar rápido
    config = function()
      -- Mapeo para aceptar la sugerencia con <C-J> (Control + J)
      -- Por defecto es Tab, pero suele chocar con los snippets o el menú de nvim-cmp
      vim.g.copilot_no_tab_map = true
      vim.keymap.set("i", "<M-j>", 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
      })

      -- Opcional: Desactivar copilot para ciertos tipos de archivo si te molesta
      -- vim.g.copilot_filetypes = {
      --   markdown = false,
      --   help = false,
      -- }
    end,
  },

  {
    "mfussenegger/nvim-dap",
    ft = "python", -- <--- AGREGA ESTA LÍNEA (Cargar al abrir python)
    -- O si quieres que cargue con varios lenguajes: ft = {"python", "c", "cpp"},

    dependencies = {
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Configurar Python
      local path = vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(path)
    end,
  },

  -- Plugin para Jupyter (Molten)
  {
    "benlubas/molten-nvim",
    -- Activamos con ft para que cargue rápido al abrir archivos
    ft = { "python", "ipynb", "markdown", "quarto" },
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",

    init = function()
      -- 1. LA CLAVE: Reactivar Python justo aquí, dentro del plugin
      vim.g.loaded_python3_provider = nil
      vim.g.python3_host_prog = "/usr/bin/python3" -- Ruta de Fedora

      -- 2. Configuración de Molten
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
    end,
  },
  -- 1. El gestor de paquetes Lua (Debe ir primero o tener priority)
  {
    "vhyrro/luarocks.nvim",
    priority = 1000, -- Muy importante: Cargamos esto antes que nada
    config = true,
    opts = {
      rocks = {
        hererocks = true, -- Aseguramos que hererocks esté activado
      },
    },
  },

  -- 2. El plugin de Imágenes
  {
    "3rd/image.nvim",
    dependencies = { "luarocks.nvim" }, -- Le decimos que espere a luarocks
    config = function()
      require("image").setup {
        backend = "kitty", -- Asegúrate de que usas Kitty. Si usas GNOME Terminal, cambia a "ueberzug"
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
          },
        },
        max_width = nil,
        max_height = nil,
        max_height_window_percentage = 50,
      }
    end,
  },

  {
    "goolord/alpha-nvim",
    config = function()
      require("alpha").setup(require("alpha.themes.dashboard").config)
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require "lint"

      -- Configurar flake8 para python
      lint.linters_by_ft = {
        python = { "flake8" },
        tex = { "chktex" },
      }
      if lint.linters.chktex then
        lint.linters.chktex.ignore_exitcode = true
      end
      -- Activar el linter cada vez que escribes o guardas
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
