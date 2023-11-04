local mason_pack = '/home/deuru/.local/share/nvim/mason/packages'

--local null_ls = require('null-ls')
--null_ls.setup({
--    sources = {
--        null_ls.builtins.diagnostics.checkstyle.with({
--            extra_args = { "-c", mason_pack .. "/checkstyle/google_checks.xml" },
--            -- or "/sun_checks.xml" or path to self written rules
--        }),
--    }
--})

-- setting up cmp capabilities for jdtls
local jdtls = require('jdtls')
require("cmp")

-- setting up project dir
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = '/home/deuru/table/wspace/' .. project_name
--                                               ^^

-- File types that signify a Java project's root directory. This will be
-- used by eclipse to determine what constitutes a workspace
--
--
-- eclipse.jdt.ls stores project specific data within a folder. If you are working
-- with multiple different projects, each project must use a dedicated data directory.
-- This variable is used to configure eclipse to use the directory name of the
-- current project found using the root_marker as the folder for project specific data.
--local workspace_folder = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

local config = {
    cmd = {
        --
        "java", -- Or the absolute path '/path/to/java11_or_newer/bin/java'
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.level=ALL",
        "-Xms500m",
        "--add-modules=ALL-SYSTEM",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
        "-javaagent:" .. "/opt/jdtls/lombok.jar",
        --
        --
        "-jar",
        "/opt/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar",
        mason_pack .. "/google-java-format/google-java-format-*-deps.jar",
        mason_pack .. "/checkstyle/checkstyle-*.jar \"$@\"",
        "-configuration", "/opt/jdtls/config_linux",
        "-data", workspace_dir
    },
    -- 💀
    -- This is the default if not provided, you can remove it. Or adjust as needed.
    -- One dedicated LSP server & client will be started per unique root_dir

    root_dir = require('jdtls.setup').find_root({ 'gradlew', 'mvnw', '.git', 'pom.xml' }),
    settings = {
        java = {
            signatureHelp = { enabled = true },
            contentProvider = { preferred = 'fernflower' },
            import = { enabled = true },
            rename = { enabled = true },
        },
        maven = {
            downloadSources = true,
        },
        implementationsCodeLens = {
            enabled = true,
        },
        referencesCodeLens = {
            enabled = true,
        },
        references = {
            includeDecompiledSources = true,
        },
        format = {
            enabled = true,
            settings = {
                url = vim.fn.stdpath "config" .. "/lang-servers/intellij-java-google-style.xml",
                profile = "GoogleStyle",
            },
        },
    },
    completion = {
        favoriteStaticMembers = {
            "org.hamcrest.MatcherAssert.assertThat",
            "org.hamcrest.Matchers.*",
            "org.hamcrest.CoreMatchers.*",
            "org.junit.jupiter.api.Assertions.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
            "org.mockito.Mockito.*",
        },
        importOrder = {
            "java",
            "javax",
            "com",
            "org"
        },
        overwrite = true,
    },
    sources = {
        organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
        },
    },
    codeGeneration = {
        toString = {
            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
        useBlocks = true,
    },
    flags = {
        allow_incremental_sync = true,
    },
    init_options = {
        bundles = {}
    },

    -- assining cap
    capabilities = require('cmp_nvim_lsp').default_capabilities()
}

--config['on_attach'] = function(client, bufnr)
--    require 'keymaps'.map_java_keys(bufnr);
--    require "lsp_signature".on_attach({
--        bind = true, -- This is mandatory, otherwise border config won't get registered.
--        floating_window_above_cur_line = false,
--        padding = '',
--        handler_opts = {
--            border = "rounded"
--        }
--    }, bufnr)
--end


jdtls.jol_path = '/opt/jol/jol-cli-0.9-full.jar'

--
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
jdtls.start_or_attach(config)
print("Created work space: " .. workspace_dir)


local opts = { noremap = true, silent = true }
--[[IMPORT]]
vim.api.nvim_set_keymap('n', '<leader>o', '<cmd>lua require("jdtls").organize_imports()<CR>', opts)
--[[EXTVAR]]
vim.keymap.set({ 'n', 'v' }, '<leader>ev', '<cmd>lua require("jdtls").extract_variable()<CR>', opts)
--[[EXT METH]]
vim.keymap.set({ 'n', 'v' }, '<leader>em', '<cmd>lua require("jdtls").extract_method()<CR>', opts)
--[[JOL]]
vim.api.nvim_set_keymap('n', '<leader>jo', '<C-w>s <cmd>lua require("jdtls").jol()<CR>', opts)

vim.api.nvim_set_keymap("n", "<leader>/", "<plug>kommentary_line_default", {})
vim.api.nvim_set_keymap("v", "<leader>/", "<plug>kommentary_visual_default", {})


-- vim.api.nvim_exec([[
--          hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
--          hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
--          hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
--          augroup lsp_document_highlight
--            autocmd!
--            autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
--            autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
--          augroup END
--      ]], false)



--" If using nvim-dap
--" This requires java-debug and vscode-java-test bundles, see install steps in this README further below.
--nnoremap <leader>df <Cmd>lua require'jdtls'.test_class()
--nnoremap <leader>dn <Cmd>lua require'jdtls'.test_nearest_method()
