local mason_pack = '/home/deuru/.local/share/nvim/mason/packages'

-- setting up cmp capabilities for jdtls
local jdtls = require('jdtls')
require("cmp")

-- setting up project dir
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = '/home/deuru/table/wspace/' .. project_name

local root_dir = require('jdtls.setup').find_root({ 'gradlew', 'mvnw', '.git', 'pom.xml' })


local extendedClientCapabilities = require('jdtls').extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true


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
        '-Dlog.protocol=true',
        "-Dlog.level=ALL",

        "-XX:+UseParallelGC",
        "-XX:GCTimeRatio=4",
        "-XX:AdaptiveSizePolicyWeight=90",
        "-Dsun.zip.disableMemoryMapping=true",
        "-Xmx1G",
        "-Xms100m",

        --"-Xms3g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
        "-javaagent:" .. "/opt/jdtls/lombok.jar",
        --
        --
        "-jar",
        "/opt/jdtls-latest/plugins/org.eclipse.equinox.launcher_1.6.600.v20231012-1237.jar",
        "-configuration", "/opt/jdtls-latest/config_linux",
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

            maven = {
                downloadSources = true,
            },
            implementationsCodeLens = {
                enabled = true,
            },
            referenceCodeLens = {
                enabled = true,
            },
            references = {
                includeAccessors = true,
                includeDecompiledSources = true,
            },

            --            format = {
            --                enabled = true,
            --                settings = {
            --                    url = mason_pack .. "/google-java-format/google_checks.xml",
            --                    profile = "GoogleStyle",
            --                },
            --           },

            --        /**
            --         * Enable/disable the signature help,
            --         * default is false
            --         */
            --        signatureHelp?: SignatureHelpOption;
            --        sources?: SourcesOption;
            --          symbols = {
            --            includeSourceMethodDeclarations = false
            --          },
            --        templates?: TemplatesOption;
            --        trace?: TraceOptions;
            --        edit?: EditOption;




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
        bundles =
            vim.list_extend(
                vim.split(
                    vim.fn.glob("~/table/space/vscode-java-test/server/*.jar", true),
                    "\n"),

                { vim.fn.glob(mason_pack ..
                    "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar")
                }
            )

    },

    -- assining cap
    capabilities = require('cmp_nvim_lsp').default_capabilities()
}



-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
jdtls.start_or_attach(config)

-- Key-binds
vim.keymap.set('n', '<leader>o',
    function() jdtls.organize_imports() end,
    { desc = "Java Import", silent = true }
)

vim.keymap.set({ 'n', 'v' }, '<leader>ev', function()
        local mode = vim.api.nvim_get_mode()['mode']
        if mode == 'v' or mode == 'V' then
            Exit_visual()
            jdtls.extract_variable({ visual = true })
        else
            jdtls.extract_variable()
        end
    end,
    { desc = "Java [E]xtract [V]ariable", silent = true }
)
vim.keymap.set({ 'n', 'v' }, '<leader>em', function()
        local mode = vim.api.nvim_get_mode()['mode']
        if mode == 'v' or mode == 'V' then
            Exit_visual()
            jdtls.extract_method({ visual = true })
        else
            jdtls.extract_method()
        end
    end,
    { desc = "Java [E]xtract [M]ethod", silent = true }
)


vim.keymap.set('n', '<leader>jo',
    function() jdtls.jol() end,
    { desc = "Java [Jo]l", silent = true }
)



vim.api.nvim_create_autocmd({ "LspAttach" }, {
    pattern = '*.java',
    callback = function(args)
        vim.keymap.set({ 'n', 'v' }, "<leader>f",
            function()
                local mode = vim.api.nvim_get_mode()['mode']
                if mode == 'v' or mode == 'V' then
                    Exit_visual()

                    local s = vim.fn.getpos("'<")[2]
                    local e = vim.fn.getpos("'>")[2]
                    vim.cmd(s .. ',' .. e .. "FormatLines")
                else
                    vim.cmd("FormatCode")
                end
            end,
            { desc = "Java [F]ormat", buffer = args.buf }
        )
    end
})

vim.keymap.set("n", "<leader>df",
    function() jdtls.test_class({}) end,
    { desc = "Java Test Class" }
)
vim.keymap.set("n", "<leader>tm",
    function() jdtls.test_nearest_method({}) end,
    { desc = "Java [T]est Nearest [M]ethod" }
)


vim.cmd("setlocal tabstop=2")
vim.cmd("setlocal softtabstop=2")
vim.cmd("setlocal shiftwidth=2")
vim.cmd("setlocal colorcolumn = \"100\"")

-- Setting up Google Formater
local format_path = vim.fn.glob(mason_pack .. "/google-java-format/google-java-format-1.20.0-all-deps.jar")
vim.cmd("Glaive codefmt google_java_executable=\"java -jar " .. format_path .. "\"");

jdtls.jol_path = '/opt/jol/jol-cli-0.9-full.jar'

--- Exits visual mode
function Exit_visual()
    local mode = vim.api.nvim_get_mode()['mode']
    if mode ~= 'v' and mode ~= 'V' then
        error("Exit_visual(): Can't exit visual mode because it isn't in visual mode")
        return
    end

    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
        "x", false
    )
end
