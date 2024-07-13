-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim"
  },
  cmd = "Neotree",
  keys = {
    {"<leader>e", ":NvimTreeFindFile<Cr>", {desc = "Nvim tree"}}
  },
  opts = {
    disable_netrw = true,
    hijack_netrw = true,
    open_on_tab = false,
    hijack_cursor = false,
    update_cwd = false,
    diagnostics = {
      enable = false,
      icons = {
        hint = "",
        info = "",
        warning = "",
        error = ""
      }
    },
    update_focused_file = {
      enable = false,
      update_cwd = false,
      ignore_list = {}
    },
    system_open = {
      cmd = nil,
      args = {}
    },
    actions = {
      open_file = {
        quit_on_open = true
      }
    },
    git = {
      enable = false
    },
    renderer = {
      highlight_opened_files = "icon"
    },
    view = {
      adaptive_size = true,
      centralize_selection = true,
      number = true,
      relativenumber = true,
      width = 50,
      side = "left"
    },
    filters = {
      dotfiles = false,
      custom = {}
    }
  }
}
