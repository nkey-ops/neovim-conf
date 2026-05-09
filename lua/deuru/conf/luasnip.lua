local ls = require("luasnip")
local extras = require("luasnip.extras")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt

local opts = {delimiters = "<>"}

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
        s("$", fmt("${}$", { i(1) })),
        s("$$", fmt("$${}$$", { i(1) })),
        s(":$", fmt("\\:${}$:\\", { i(1) })),
        s("t", fmt("\\times {}", { i(1) })),
        s("d", fmt("\\cdot {}", { i(1) })),
        s("im", fmt("\\implies {}", { i(1) })),
        s("cr", fmt([[\circ]], {}, {})),
        s("par", fmt([[\parallel]], {}, {})),

        s("nq", fmt("\\neq {}", { i(1) })),
        s("lq", fmt("\\leq {}", { i(1) })),
        s("gq", fmt("\\geq {}", { i(1) })),

        s("an", fmt([[\angle{<>}]], { i(1) }, opts)),
        s("tr", fmt("\\triangle{{{}}}", { i(1) })),
        s("ol", fmt("\\overline{{{}}}", { i(1) })),
        s("ln", fmt("\\overleftrightarrow{{{}}}", { i(1) })),
        s("arc", fmt("\\overset{{\\frown}}{{{}}}", { i(1) })),
        s("sr", fmt([[\sqrt{<>}]], { i(1) }, { delimiters = "<>" })),

        s("sin", fmt([[\sin(<>)]], { i(1) }, { delimiters = "<>" })),
        s("cos", fmt([[\cos(<>)]], { i(1) }, { delimiters = "<>" })),
        s("tan", fmt([[\tan(<>)]], { i(1) }, { delimiters = "<>" })),
        s("asin", fmt([[\arcsin(<>)]], { i(1) }, { delimiters = "<>" })),
        s("acos", fmt([[\arccos(<>)]], { i(1) }, { delimiters = "<>" })),
        s("atan", fmt([[\arctan(<>)]], { i(1) }, { delimiters = "<>" })),

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


ls.add_snippets("http",
    {
        s("plua", fmt(
            [[
            # @lang lua
            < {{%
            {}
            %}}
            ]],
            { i(1) })),
        s("alua", fmt(
            [[
            # @lang lua
            > {{%
            {}
            %}}
            ]],
            { i(1) })),
        s("cjson", fmt("Content-Type: application/json", {})),
        s("cform", fmt("Content-Type: application/x-www-form-urlencoded", {}))
    })
