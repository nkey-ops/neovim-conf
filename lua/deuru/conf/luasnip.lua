local ls = require("luasnip")
local extras = require("luasnip.extras")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("markdown",
    {
        s("env", fmt([[
    \begin{{{}}}
        {}
    \end{{{}}}
  ]], {
            i(1, "environment"),
            i(2),
            rep(1),
        })),
        s("$", fmt("$\\Large {}$", { i(1) })),
        s("$$", fmt([[
            $$\large
            {}
            $$
        ]], { i(1) })),
        s(":$", fmt("\\:${}$:\\", { i(1) })),
        s("t", fmt("\\times {}", { i(1) })),
        s("d", fmt("\\cdot {}", { i(1) })),
        s("im", fmt("\\implies {}", { i(1) })),
        s("nq", fmt("\\neq {}", { i(1) })),
        s("lq", fmt("\\leq {}", { i(1) })),
        s("gq", fmt("\\geq {}", { i(1) })),
        s("fr", fmt(
            [[
            \frac{{{}}}{{{}}}
            ]], {
                i(1),
                i(2),
            })),
        s("bal", fmt(
            [[
            \begin{{align*}}
            {}  &= {} \\
                &= {} \\
            \end{{align*}}
            ]], {
                i(1),
                i(2),
                i(3)
            }
        )),
        s("cas", fmt(
            [[
            \begin{{cases}}
            {}
            \end{{cases}}
            ]], {
                i(1),
            }
        ))
    })
