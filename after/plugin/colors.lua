function ColorMyPencils(color)
    -- darcula-solid \ nordic |  rose-pine
    color = color or "catppuccin-mocha"
    -- " catppuccin-latte, catppuccin-frappe,
    --  catppuccin-macchiato, catppuccin-mocha

  vim.cmd.colorscheme(color)

 -- vim.api.nvim_set_hl(0, "Normal", { blend=0 })
 -- vim.api.nvim_set_hl(0, "NormalNC", { bg = 'none'})
 -- vim.api.nvim_set_hl(0, "NormalFloatNC", { bg = "none" })

end

ColorMyPencils()
