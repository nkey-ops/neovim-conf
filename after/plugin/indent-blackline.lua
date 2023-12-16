--require("ibl").setup()
--    local highlight = {
--    "CursorColumn",
--    "Whitespace",
--}
--require("ibl").setup {
--    indent = { highlight = highlight, char = "|" },
--    --whitespace = {
--    --    highlight = highlight,
--    --    remove_blankline_trail = false,
--    --},
--    --scope = { enabled = false },
--}


require("ibl").setup {
    indent = {char = "┋" },
    scope = {
        enabled = true,
        show_exact_scope = true
    },
}
