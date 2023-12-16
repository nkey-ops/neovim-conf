local function db_completion()
  require("cmp").setup.buffer {
      sources = {
          { name = "vim-dadbod-completion"
      } }
  }
end

local function setup()
  vim.g.db_ui_save_location = '~/.config/db_ui'

  vim.api.nvim_create_autocmd("FileType", {
    pattern = {
      "sql",
      "mysql",
      "plsql",
    },
    callback = function()
      vim.schedule(db_completion)
    end,
  })
end


vim.keymap.set("n", "<leader>du", "<cmd>DBUIToggle<CR>")

setup()
