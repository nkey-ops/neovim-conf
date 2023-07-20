-- setting up cmp capabilities for jdtls
local jdtls = require('jdtls')


local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

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
        "-Xms1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
       "-javaagent:" .. "/opt/jdtls/lombok.jar",
        --
        "-jar", "/opt/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar",
     	"-configuration", "/opt/jdtls/config_linux",
        "-data", workspace_dir
    },
    -- 💀
    -- This is the default if not provided, you can remove it. Or adjust as needed.
    -- One dedicated LSP server & client will be started per unique root_dir

    root_dir = require('jdtls.setup').find_root({'gradlew', 'mvnw', '.git', 'pom.xml' }),
    settings = {
        java = {
            signatureHelp = {enabled = true},
            import = {enabled = true},
            rename = {enabled = true}
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
    signatureHelp = { enabled = true },
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
    capabilities = capabilities
}

config['on_attach'] = function(client, bufnr)
    require'keymaps'.map_java_keys(bufnr);
    require "lsp_signature".on_attach({
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        floating_window_above_cur_line = false,
        padding = '',
        handler_opts = {
            border = "rounded"
        }
    }, bufnr)
end

--
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require('jdtls').start_or_attach(config)
print("Created work space: " .. workspace_dir)



local opts = {noremap=true, silent=true}

--[[]]vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
--[[]]vim.api.nvim_set_keymap('n',  'gD',               '<cmd>lua vim.lsp.buf.declaration ()<CR>', opts)
--[[DEFINI]] vim.api.nvim_set_keymap('n', 'gd',         '<cmd>lua vim.lsp.buf.definition ()<CR>', opts)
--[[HOVER]]  vim.api.nvim_set_keymap('n', 'K',          '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
--[[]]       vim.api.nvim_set_keymap('n', 'gi',         '<cmd>lua vim.lsp.buf.implementation ()<CR>', opts)
--[[]]       vim.api.nvim_set_keymap('n', '<leader>k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
--[[]]       vim.api.nvim_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
--[[]]       vim.api.nvim_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
--[[]]       vim.api.nvim_set_keymap('n', '<leader>wl', '<cmd>lua print (vim.inspect (vim. lsp.buf.list_workspace_folders()))<CR>', opts)
--[[]]       vim.api.nvim_set_keymap('n', '<leader>D',  '<cmd>lua vim.lsp.buf.type_definition ()<CR>', opts)
--[[RENAME]] vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
--[[]]       vim.api.nvim_set_keymap('n', 'gr',         '<cmd>lua vim.lsp.buf.references()<CR>', opts)
--[[]]       vim.api.nvim_set_keymap('n', '<leader>e',  '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
--[[]]       vim.api.nvim_set_keymap('n', '[d',         '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
--[[]]       vim.api.nvim_set_keymap('n', 'Id',         '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
--[[DIAGNOS]]vim.api.nvim_set_keymap('n', '<leader>q',  '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
--[[FORMAT]] vim.api.nvim_set_keymap('n', '<leader>f',  '<cmd>lua vim.lsp.buf.format()<CR>', opts)
--[[]]       vim.api.nvim_set_keymap('n', '<leader>lg', '<cmd>lua vim.lsp.buf.formatting_sync(nil, 1000)<CR>', opts)

--[[IMPORT]] vim.api.nvim_set_keymap('n', '<leader>wo', '<cmd>lua require("jdtls").organize_imports()<CR>', opts)
--[[EXTVAR]] vim.api.nvim_set_keymap('n', '<leader>ev', '<cmd>lua require("jdtls").extract_variable()<CR>', opts)

--
--" If using nvim-dap
--" This requires java-debug and vscode-java-test bundles, see install steps in this README further below.
--nnoremap <leader>df <Cmd>lua require'jdtls'.test_class()
--nnoremap <leader>dn <Cmd>lua require'jdtls'.test_nearest_method()

