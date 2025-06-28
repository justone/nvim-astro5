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

function simple_clojure_lsp_command(command)
  local clients = vim.lsp.get_clients { name = "clojure_lsp", bufnr = 0 }
  if #clients == 0 then
    vim.notify("clojure-lsp not available", vim.log.levels.WARN)
    return
  end

  local client = clients[1]
  local params = {
    command = command,
    arguments = {
      vim.uri_from_bufnr(0),
      vim.fn.line "." - 1,
      vim.fn.col "." - 1,
    },
  }

  client.request("workspace/executeCommand", params, nil, 0)
end

function prompted_clojure_lsp_command(command, prompt_text)
  local clients = vim.lsp.get_clients { name = "clojure_lsp", bufnr = 0 }
  if #clients == 0 then
    vim.notify("clojure-lsp not available", vim.log.levels.WARN)
    return
  end

  -- Prompt user for input
  local user_input = vim.fn.input(prompt_text or "Enter value: ")
  if user_input == "" then
    vim.notify("Operation cancelled", vim.log.levels.INFO)
    return
  end

  local client = clients[1]
  local params = {
    command = command,
    arguments = {
      vim.uri_from_bufnr(0),
      vim.fn.line "." - 1,
      vim.fn.col "." - 1,
      user_input,
    },
  }

  client.request("workspace/executeCommand", params, nil, 0)
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
    "viniciusgerevini/tmux-runner.vim",
    cmd = "TmuxRunnerPromptCommand",
    config = function() vim.g.TmuxRunnerNewRunnerMode = "nearest" end,
    keys = {
      { "<leader>tp", ":TmuxRunnerPromptCommand<CR>", desc = "Prompt and run command" },
      { "<leader>tr", ":TmuxRunnerRunLastCommand<CR>", desc = "Re run last command" },
      {
        "<leader>ty",
        function()
          vim.cmd "TmuxRunnerStop"
          vim.cmd "TmuxRunnerRunLastCommand"
        end,
        desc = "Interrupt and re-run command",
      },
      { "<leader>ti", ":TmuxRunnerInspect<CR>", desc = "Inspect command run" },
      { "<leader>tx", ":TmuxRunnerClose<CR>", desc = "Close command runner split" },
      { "<leader>tc", ":TmuxRunnerStop<CR>", desc = "Stop command" },
      { "<leader>tl", ":TmuxRunnerClear<CR>", desc = "Clear pane" },
      { "<leader>tz", ":TmuxRunnerZoom<CR>", desc = "Zoom in command runner split" },
    },
  },
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
          -- Disable terminal python split
          ["<leader>tp"] = false,

          -- Go to definition in a new split
          ["gD"] = {
            function()
              vim.cmd "aboveleft split"
              require("telescope.builtin").lsp_definitions()
            end,
            desc = "Go to definition in split with telescope",
            remap = true,
          },

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

          ["<leader>cc"] = {
            function()
              local clients = vim.lsp.get_clients { name = "clojure_lsp", bufnr = 0 }
              if #clients == 0 then
                vim.notify("clojure-lsp not available", vim.log.levels.WARN)
                return
              end

              -- Request server capabilities to see available commands
              local client = clients[1]
              if client.server_capabilities.executeCommandProvider then
                local commands = client.server_capabilities.executeCommandProvider.commands
                vim.notify("Available commands: " .. vim.inspect(commands))
              else
                vim.notify "Server doesn't support executeCommand"
              end
            end,
            desc = "List available LSP commands",
          },

          -- Converted Clojure LSP mappings for AstroNvim
          ["<p"] = {
            function() simple_clojure_lsp_command "drag-backward" end,
            desc = "Drag backward (Clojure LSP)",
          },
          [">p"] = {
            function() simple_clojure_lsp_command "drag-forward" end,
            desc = "Drag forward (Clojure LSP)",
          },

          -- An attempt to make which-key sub-menus for Clojure LSP commands
          -- ["cr"] = { name = "Clojure Refactor" },
          -- ["cre"] = { name = "Extract" },
          -- ["cri"] = { name = "Introduce" },
          -- ["crm"] = { name = "Move" },

          ["crcc"] = {
            function() simple_clojure_lsp_command "cycle-coll" end,
            desc = "Cycle collection (Clojure LSP)",
          },
          ["crsm"] = {
            function() simple_clojure_lsp_command "sort-clauses" end,
            desc = "Sort clauses (Clojure LSP)",
          },
          ["crth"] = {
            function() simple_clojure_lsp_command "thread-first" end,
            desc = "Thread first (Clojure LSP)",
          },
          ["crtt"] = {
            function() simple_clojure_lsp_command "thread-last" end,
            desc = "Thread last (Clojure LSP)",
          },
          ["crtf"] = {
            function() simple_clojure_lsp_command "thread-first-all" end,
            desc = "Thread first all (Clojure LSP)",
          },
          ["crtl"] = {
            function() simple_clojure_lsp_command "thread-last-all" end,
            desc = "Thread last all (Clojure LSP)",
          },
          ["cruw"] = {
            function() simple_clojure_lsp_command "unwind-thread" end,
            desc = "Unwind thread (Clojure LSP)",
          },
          ["crua"] = {
            function() simple_clojure_lsp_command "unwind-all" end,
            desc = "Unwind all (Clojure LSP)",
          },
          ["crel"] = {
            function() simple_clojure_lsp_command "expand-let" end,
            desc = "Expand let (Clojure LSP)",
          },
          ["cram"] = {
            function() simple_clojure_lsp_command "add-missing-libspec" end,
            desc = "Add missing libspec (Clojure LSP)",
          },
          ["crab"] = {
            function() simple_clojure_lsp_command "drag-param-backward" end,
            desc = "Drag param backward (Clojure LSP)",
          },
          ["craf"] = {
            function() simple_clojure_lsp_command "drag-param-forward" end,
            desc = "Drag param forward (Clojure LSP)",
          },
          ["crai"] = {
            function() simple_clojure_lsp_command "add-missing-import" end,
            desc = "Add missing import (Clojure LSP)",
          },
          ["crcn"] = {
            function() simple_clojure_lsp_command "clean-ns" end,
            desc = "Clean namespace (Clojure LSP)",
          },
          ["crcp"] = {
            function() simple_clojure_lsp_command "cycle-privacy" end,
            desc = "Cycle privacy (Clojure LSP)",
          },
          ["crck"] = {
            function() simple_clojure_lsp_command "cycle-keyword-auto-resolve" end,
            desc = "Cycle keyword auto-resolve (Clojure LSP)",
          },
          ["cris"] = {
            function() simple_clojure_lsp_command "inline-symbol" end,
            desc = "Inline symbol (Clojure LSP)",
          },
          ["crdk"] = {
            function() simple_clojure_lsp_command "destructure-keys" end,
            desc = "Destructure keys (Clojure LSP)",
          },
          ["crrk"] = {
            function() simple_clojure_lsp_command "restructure-keys" end,
            desc = "Restructure keys (Clojure LSP)",
          },
          ["crcf"] = {
            function() simple_clojure_lsp_command "create-function" end,
            desc = "Create function (Clojure LSP)",
          },

          -- Prompted Clojure LSP mappings for AstroNvim
          ["crml"] = {
            function() prompted_clojure_lsp_command("move-to-let", "Binding name: ") end,
            desc = "Move to let (Clojure LSP)",
          },
          ["cril"] = {
            function() prompted_clojure_lsp_command("introduce-let", "Binding name: ") end,
            desc = "Introduce let (Clojure LSP)",
          },
          ["cref"] = {
            function() prompted_clojure_lsp_command("extract-function", "Function name: ") end,
            desc = "Extract function (Clojure LSP)",
          },
          ["cred"] = {
            function() prompted_clojure_lsp_command("extract-to-def", "Def name: ") end,
            desc = "Extract to def (Clojure LSP)",
          },

          ["<leader>ci"] = {
            function()
              local params = {
                command = "cursor-info",
                arguments = {},
              }

              vim.lsp.buf_request(0, "workspace/executeCommand", params, function(err, result)
                if err then
                  vim.notify("Command failed: " .. tostring(err.message), vim.log.levels.ERROR)
                else
                  vim.notify("Cursor info: " .. vim.inspect(result))
                end
              end)
            end,
            desc = "Get cursor info (test command)",
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
      mappings = {
        n = {
          -- Don't use default LSP definition mapping
          ["gD"] = false,
        },
      },
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
