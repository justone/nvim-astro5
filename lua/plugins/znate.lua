return {
  { "folke/noice.nvim", enabled = false },
  { "mg979/vim-visual-multi", enabled = false },
  { "justone/vim-pmb", lazy = false },
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
  { "AstroNvim/astrocommunity", { import = "astrocommunity.recipes.disable-tabline" } },
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
        },
        t = {
          -- terminal mode key bindings
          ["jj"] = { "<C-\\><C-n>", silent = true },
        },
        v = {
          -- visual mode key bindings
        },
      },
    },
  },
}
