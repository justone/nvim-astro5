function telescope_multi(prompt_bufnr, methstr)
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local picker = action_state.get_current_picker(prompt_bufnr)
  local multi_selection = picker:get_multi_selection()

  -- print("Multi-selection count:", #multi_selection)
  -- for i, entry in ipairs(multi_selection) do
  --   print("Entry " .. i .. ":", entry.path or entry.filename or entry.value)
  -- end

  -- Check if current buffer is blank (unnamed and unmodified)
  local current_buf = vim.fn.bufnr "#"
  local is_blank_buffer = vim.api.nvim_buf_get_name(current_buf) == ""
    and not vim.api.nvim_buf_get_option(current_buf, "modified")
    and vim.api.nvim_buf_line_count(current_buf) == 1
    and vim.api.nvim_buf_get_lines(current_buf, 0, 1, false)[1] == ""

  if #multi_selection > 0 then
    actions.close(prompt_bufnr)
    for _, entry in ipairs(multi_selection) do
      local file_path = entry.path or entry.filename or entry.value
      -- print("Opening in tab:", file_path)
      if file_path then vim.cmd(methstr .. " " .. vim.fn.fnameescape(file_path)) end
    end
  else
    if methstr == "tabedit" then
      actions.select_tab(prompt_bufnr)
    elseif methstr == "vsplit" then
      actions.select_vertical(prompt_bufnr)
    elseif methstr == "split" then
      actions.select_horizontal(prompt_bufnr)
    end
  end

  if is_blank_buffer and vim.api.nvim_buf_is_valid(current_buf) then
    vim.api.nvim_buf_delete(current_buf, { force = false })
  end
end

-- Open fugitive status on top and within a reasonable height
vim.api.nvim_create_autocmd("FileType", {
  pattern = "fugitive",
  callback = function()
    vim.cmd "wincmd K"

    local line_count = vim.api.nvim_buf_line_count(0)
    local height = math.min(math.max(line_count + 2, 8), 20)
    vim.cmd("resize " .. height)
  end,
})

-- vim.opt.verbose = 1
-- vim.lsp.set_log_level "debug"

return {
  -- Disabled plugins
  -- Takes over the command line, don't want
  { "folke/noice.nvim", enabled = false },
  -- Unneeded and conflicts with my tab navigation bindings
  { "mg979/vim-visual-multi", enabled = false },

  -- Disable paredit/parinfer and switch back to vim-sexp/vim-sexp-mappings-for-regular-people
  { "dundalek/parpar.nvim", enabled = false },
  { "gpanders/nvim-parinfer", enabled = false },
  { "julienvincent/nvim-paredit", enabled = false },
  { "guns/vim-sexp", ft = { "clojure", "fennel", "scheme", "commonlisp" } },
  { "tpope/vim-sexp-mappings-for-regular-people", ft = { "clojure", "fennel", "scheme", "commonlisp" } },

  -- Switch back to Obsession
  { "stevearc/resession.nvim", enabled = false },
  { "tpope/vim-obsession", cmd = "Obsession" },

  -- Restore the other tpope plugins
  { "tpope/vim-abolish", lazy = false },
  { "tpope/vim-eunuch", lazy = false },
  { "tpope/vim-fugitive", lazy = false },
  { "tpope/vim-repeat", lazy = false },
  { "tpope/vim-rhubarb", lazy = false },
  { "tpope/vim-speeddating", lazy = false },
  { "tpope/vim-unimpaired", lazy = false },

  -- My plugins
  { "justone/vim-pmb", lazy = false },
  { "gcmt/taboo.vim", lazy = false },
  {
    "https://github.com/mileszs/ack.vim.git",
    lazy = false,
    config = function()
      vim.cmd "cnoreabbrev Ack Ack!"
      vim.cmd "cnoreabbrev Rg Ack!"
      vim.cmd "cnoreabbrev Rgc Ack! --no-ignore-vcs --type clojure --type edn"

      vim.g.ackprg = "rg --vimgrep --smart-case --hidden --glob '!{.git,node_modules}/*'"
    end,
    keys = {
      { "<leader>A", ":Ack!<cr>", desc = "Search for current word" },
      { "<leader>S", ":Ack!<space>", desc = "Search with Ack" },
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

  -- Community overrides
  {
    "AstroNvim/astrocommunity",
    { import = "astrocommunity.recipes.disable-tabline" },
    { import = "astrocommunity.lsp.lspsaga-nvim" },
    { import = "astrocommunity.lsp.lsp-signature-nvim" },
    { import = "astrocommunity.fuzzy-finder.telescope-nvim" },
    { import = "astrocommunity.completion.nvim-cmp" },
    { import = "astrocommunity.recipes.telescope-lsp-mappings" },
    { import = "astrocommunity.pack.java" },

    { import = "astrocommunity.completion.copilot-vim" },
    { import = "astrocommunity.completion.copilot-vim-cmp" },

    { import = "astrocommunity.git.octo-nvim" },
    { import = "astrocommunity.git.mini-diff" },
  },

  -- Setting the colorscheme
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
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      options = {
        opt = {
          cmdheight = 1,
          mouse = "nvi",
          number = false,
          relativenumber = false,
          scrolloff = 5,
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
        -- Normal mode mappings
        n = {
          -- Tab navigation
          ["<C-N>"] = { ":tabnext<CR>" },
          ["<C-P>"] = { ":tabprev<CR>" },

          -- Scroll faster
          ["<C-e>"] = { "3<C-e>" },
          ["<C-y>"] = { "3<C-y>" },

          -- Keep cursor in the middle of the screen when scrolling or navigating search matches
          ["<C-u>"] = { "<C-u>zz" },
          ["<C-d>"] = { "<C-d>zz" },
          ["n"] = { "nzz" },
          ["N"] = { "Nzz" },

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

          -- Custom Conjure split management. Keeps vertical or horizontal split fixed and at a good default height/width
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
        },
        t = { -- terminal mode key bindings
          -- Escape to normal mode easily
          ["jf"] = { "<C-\\><C-n>", silent = true },

          -- You might also want to override these common terminal keys
          ["<C-h>"] = { "<C-h>", desc = "Ctrl-h in terminal" },
        },
        v = { -- visual mode key bindings
        },
        x = { -- x mode key bindings
          -- `s` to start surrounding when visually selected
          ["s"] = { "<Plug>(nvim-surround-visual)" },
        },
      },
    },
  },

  -- Plugin overrides
  -- Turn off the end-of-line light bulb
  { "nvimdev/lspsaga.nvim", opts = { lightbulb = { enable = false } } },

  -- Control which filetypes are automatically formatted on save
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
            "xml",
          },
        },
      },
    },
  },

  -- Telescope tweaks
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        -- Add binding to only find recent files in local directory
        "<leader>fl",
        function() require("telescope.builtin").oldfiles { cwd_only = true } end,
        desc = "Find history (CWD)",
      },
    },
    opts = {
      defaults = {
        -- Add ability to open multi-selected files in multiple splits/vsplits/tabs
        mappings = {
          i = {
            ["<C-t>"] = function(prompt_bufnr) telescope_multi(prompt_bufnr, "tabedit") end,
            ["<C-v>"] = function(prompt_bufnr) telescope_multi(prompt_bufnr, "vsplit") end,
            ["<C-x>"] = function(prompt_bufnr) telescope_multi(prompt_bufnr, "split") end,
          },
          n = {
            ["<C-t>"] = function(prompt_bufnr) telescope_multi(prompt_bufnr, "tabedit") end,
            ["<C-v>"] = function(prompt_bufnr) telescope_multi(prompt_bufnr, "vsplit") end,
            ["<C-x>"] = function(prompt_bufnr) telescope_multi(prompt_bufnr, "split") end,
            ["t"] = function(prompt_bufnr) telescope_multi(prompt_bufnr, "tabedit") end,
            ["v"] = function(prompt_bufnr) telescope_multi(prompt_bufnr, "vsplit") end,
            ["x"] = function(prompt_bufnr) telescope_multi(prompt_bufnr, "split") end,
          },
        },
      },
      pickers = {
        find_files = { theme = "ivy" },
        git_files = { theme = "ivy" },
        oldfiles = { theme = "ivy" },
      },
    },
  },

  -- For debugging
  {
    "folke/snacks.nvim",
    opts = {
      -- notifier = { enabled = false },
      -- Disable dashboard, confuses tabs
      dashboard = { enabled = false },
    },
  },
}
