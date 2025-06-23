return {
  -- Disabled plugins
  { "folke/noice.nvim", enabled = false },
  { "mg979/vim-visual-multi", enabled = false },
  { "dundalek/parpar.nvim", enabled = false },
  { "gpanders/nvim-parinfer", enabled = false },

  -- Switch back to Obsession
  { "stevearc/resession.nvim", enabled = false },
  { "tpope/vim-obsession", cmd = "Obsession" },

  -- My plugins
  { "justone/vim-pmb", lazy = false },
  { "gcmt/taboo.vim", lazy = false },
  { import = "astrocommunity.colorscheme.aurora" },
  ---@type LazySpec
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      colorscheme = "aurora",
    },
  },
  {
    "inkarkat/vim-mark",
    dependencies = { "inkarkat/vim-ingo-library" },
    lazy = false,
    keys = {
      { "<Leader>M", "<Plug>MarkToggle", desc = "Toggle all marks" },
      { "<Leader>N", "<Plug>MarkAllClear", desc = "Clear all marks" },
      -- Had to set these two so that there are no conflicting mappings
      { "<Leader>xn", "<Plug>MarkClear", desc = "Clear mark" },
      { "<Leader>x/", "<Plug>MarkSearchAnyNext", desc = "Any next" },
      { "<Leader>xr", "<Plug>MarkRegex", desc = "Mark regex" },
      { "<Leader>xr", "<Plug>MarkRegex", desc = "Mark regex", mode = "x" },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      -- notifier = { enabled = false },
      -- dashboard = { enabled = false },
    },
  },
  {
    "AstroNvim/astrocommunity",
    { import = "astrocommunity.recipes.disable-tabline" },
    { import = "astrocommunity.lsp.lspsaga-nvim" },
    { import = "astrocommunity.lsp.lsp-signature-nvim" },
    { import = "astrocommunity.fuzzy-finder.telescope-nvim" },
    { import = "astrocommunity.completion.nvim-cmp" },
  },
  { "nvimdev/lspsaga.nvim", opts = { lightbulb = { enable = false } } },
  {
    "AstroNvim/astrolsp",
    opts = {
      formatting = {
        format_on_save = {
          enabled = true,
          -- enable format on save for specified filetypes only
          -- allow_filetypes = {
          --   "go",
          -- },
          -- disable format on save for specified filetypes
          ignore_filetypes = {
            "clojure",
          },
        },
      },
    },
  },
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      options = {
        opt = {
          cmdheight = 1,
          mouse = "nvi",
          number = false,
          relativenumber = false,
        },
        g = {
          -- vim-mark config
          mwDefaultHighlightingPalette = "maximum",

          -- Conjure config
          ["conjure#client#clojure#nrepl#connection#auto_repl#hidden"] = false,
          ["conjure#log#hud#open_when"] = "log-win-not-visible",
          ["conjure#mapping#log_split"] = "lxs",
          ["conjure#mapping#log_vsplit"] = "lxv",
          ["conjure#log#hud#enabled"] = true,
          ["conjure#client#clojure#nrepl#test#runner"] = "clojure",

          -- Aurora color scheme
          aurora_transparent = 1,
        },
      },
      mappings = {
        n = {
          -- Tab navigation
          ["<C-N>"] = { ":tabnext<CR>" },
          ["<C-P>"] = { ":tabprev<CR>" },

          -- Easily toggle folds
          ["<space>"] = { "za" },

          -- Key mappings for file operations in current directory
          ["<leader>ew"] = {
            function() vim.api.nvim_feedkeys(":e " .. vim.fn.expand "%:.:h" .. "/", "n", false) end,
            desc = "Edit file in current directory",
          },
          ["<leader>es"] = {
            function() vim.api.nvim_feedkeys(":sp " .. vim.fn.expand "%:.:h" .. "/", "n", false) end,
            desc = "Split horizontal and edit file",
          },
          ["<leader>ev"] = {
            function() vim.api.nvim_feedkeys(":vsp " .. vim.fn.expand "%:.:h" .. "/", "n", false) end,
            desc = "Split vertical and edit file",
          },
          ["<leader>et"] = {
            function() vim.api.nvim_feedkeys(":tabe " .. vim.fn.expand "%:.:h" .. "/", "n", false) end,
            desc = "New tab and edit file",
          },

          ["<Leader>lv"] = {
            function()
              vim.cmd "ConjureLogVSplit"
              vim.cmd "setlocal winfixwidth"
              vim.cmd "vertical resize 80"
              vim.cmd "wincmd p"
            end,
            desc = "Open Conjure log in vertical split",
          },
          ["<Leader>ls"] = {
            function()
              vim.cmd "ConjureLogSplit"
              vim.cmd "setlocal winfixheight"
              vim.cmd "resize 12"
              vim.cmd "wincmd p"
            end,
            desc = "Open Conjure log in horizontal split",
          },

          -- LSP Saga
          ["<Leader>K"] = { ":Lspsaga hover_doc<cr>" },
        },
        t = {
          -- terminal mode key bindings
          ["jj"] = { "<C-\\><C-n>", silent = true },
        },
        v = {
          -- visual mode key bindings
        },
        x = {
          -- x mode key bindings
          ["s"] = { "<Plug>(nvim-surround-visual)" },
        },
      },
    },
  },
}
