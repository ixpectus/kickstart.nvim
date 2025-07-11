return {
  -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',
      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',
      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    -- Telescope is a fuzzy finder that comes with a lot of different things that
    -- it can fuzzy find! It's more than just a "file finder", it can search
    -- many different aspects of Neovim, your workspace, LSP, and more!
    --
    -- The easiest way to use Telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- After running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of `help_tags` options and
    -- a corresponding preview of the help.
    --
    -- Two important keymaps to use while in Telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- Telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      --
      -- defaults = {
      --   mappings = {
      --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
      --   },
      -- },
      pickers = {
        lsp_references = {
          prompt_title = 'LSP References',
          layout_config = { height = 15, width = 0.9 },
          theme = 'dropdown',
          show_line = false,
          fname_width = 100,
          path_display = {},
        },
        buffers = {
          sort_lastused = true,
          ignore_current_buffer = true,
          theme = 'ivy',
          previewer = false,
        },
        lsp_document_symbols = {
          sort_lastused = true,
          symbol_width = 100,
          show_line = false,
          ignore_current_buffer = true,
          previewer = false,
          theme = 'ivy',
          symbols = {
            'method',
            'function',
          },
        },
        oldfiles = {
          sort_lastused = true,
          cwd_only = true,
          only_cwd = true,
          ngram_len = 2,
          ignore_current_buffer = true,
          theme = 'ivy',
          previewer = false,
        },
        find_files = {
          sort_lastused = true,
          find_command = { 'rg', '--files', '--hidden', '-g', '!.git/*' },
          layout_config = { height = 15, width = 0.9 },
          -- find_command = { "rg", "-g", "!vendor/*", "-g", "!tools/vendor/*",  "--files",  "--hidden" }
        },
        grep_string = {
          sort_lastused = true,
          find_command = { 'rg', '-g', '!vendor/*', '-g', '!tools/vendor/*', '--files' },
          layout_config = { height = 15, width = 0.9 },
          theme = 'dropdown',
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<C-p>', function()
      builtin.find_files(require('telescope.themes').get_ivy { previewer = false })
    end, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>gd', builtin.lsp_document_symbols, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader><leader>', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<Space>', builtin.buffers, { desc = '[ ] Find existing buffers' })
    vim.api.nvim_create_user_command('Rg', function(opts)
      local grepOpts = {
        additional_args = {},
      }
      for k, v in pairs(opts.fargs) do
        if k == 1 then
          grepOpts.search = v
        else
          table.insert(grepOpts.additional_args, '--glob=' .. v)
        end
      end
      builtin.grep_string(grepOpts)
    end, { nargs = '*' })
    vim.api.nvim_create_user_command('Rge', function(opts)
      local grepOpts = {
        use_regex = true,
        additional_args = {},
      }
      for k, v in pairs(opts.fargs) do
        if k == 1 then
          grepOpts.search = v
        else
          table.insert(grepOpts.additional_args, '--glob=' .. v)
        end
      end
      builtin.grep_string(grepOpts)
    end, { nargs = '*' })
    vim.api.nvim_create_user_command('Rgde', function(opts)
      builtin.grep_string { search = opts.args, use_regex = true, cwd = require('telescope.utils').buffer_dir() }
    end, { nargs = '?' })

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}
