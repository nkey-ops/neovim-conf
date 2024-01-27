-- Set up nvim-cmp.n

local cmp = require('cmp')
local select_opts = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engin
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)      -- For `vsnip` users.
      --luasnip.lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },

  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(4),
    ['<C-o>'] = cmp.mapping.scroll_docs(-4),
    ['<C-y>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    -- Accept currently selected item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<CR>'] = vim.NIL,


  }),

  sources = cmp.config.sources({
    { name = 'path' },
    { name = 'nvim_lsp', keyword_length = 1 },
    { name = 'vsnip',    keyword_length = 1 }, -- For vsnip users.
    -- { name = 'luasnip', keyword_length = 2}, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    --    { name = 'buffer' },
  }),

  -- FIXES jdtls word duplication
  confirmation = {
    default_behavior = require("cmp.types").cmp.ConfirmBehavior.Replace,
  },
})


-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'git' },     -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})
-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})


