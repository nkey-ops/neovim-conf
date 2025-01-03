-- setting up cmp capabilities for jdtls
local jdtls = require('jdtls')
local mason_registry = require('mason-registry')

local mason_jdtls_path = mason_registry.get_package('jdtls'):get_install_path()
local java_debug_adapter = mason_registry
    .get_package("java-debug-adapter"):get_install_path()
local java_test = mason_registry
    .get_package("java-test"):get_install_path()


assert(vim.fn.mkdir(vim.fn.glob("~") .. "/.cache/jdtls", 'p') == 1,
    "Couldn't create '~/.cache/jdtls' directory")

local Paths = {
    workspace_dir     =
        vim.fn.glob('~/.cache/jdtls/') ..
        vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t'),
    jdtls             = mason_jdtls_path,
    jdtls_launcher    = vim.fn.glob(mason_jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
    java_debug_plugin = vim.fn.glob(java_debug_adapter .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"),
    java_test_plugins = vim.split(vim.fn.glob(java_test .. "/extension/server/*.jar", true), "\n"),
    lombok            = mason_jdtls_path .. "/lombok.jar",
}

for i, x in pairs(Paths.java_test_plugins) do
    if x:match('.+org.apiguardian.*')
        or x:match('.+runner%-jar%-with%-dependencies.*')
        or x:match('.+jacocoagent.*')
    then
        Paths.java_test_plugins[i] = nil
    end
end


-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
    -- The command that starts the language server
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    cmd = {
        -- 'java', -- or
        '/usr/lib/jvm/java-21-openjdk-amd64/bin/java',
        -- depends on if `java` is in your $PATH env variable and if it points to the right version.

        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',

        '-Xmx400m',
        '-XX:ReservedCodeCacheSize=64m',
        '-XX:-UseCompressedClassPointers',
        "-Xss512k",
        "-XX:MaxRAM=500",

        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

        "-javaagent:" .. Paths.lombok,
        '-jar', Paths.jdtls_launcher,
        '-configuration', Paths.jdtls .. '/config_linux',
        '-data', Paths.workspace_dir
    },

    -- 💀
    -- This is the default if not provided, you can remove it. Or adjust as needed.
    -- One dedicated LSP server & client will be started per unique root_dir
    --
    -- vim.fs.root requires Neovim 0.10.
    -- If you're using an earlier version, use: require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),
    -- root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew" }),
    root_dir = jdtls.setup.find_root({ '.git', 'mvnw', 'gradlew', 'pom' }),
    -- Here you can configure eclipse.jdt.ls specific settings
    -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    -- for a list of options

    settings = {
        java = {
            project = {
                -- referencedLibraries =
                --     vim.split(vim.fn.glob("/usr/share/openjfx/lib/*.jar", true), "\n")

            },
            signatureHelp = { enabled = true },
            format = {
                enabled = false,
                settings = {
                    ---[1] https://github.com/redhat-developer/vscode-java/wiki/Formatter-settings
                    --  [2] https://github.com/redhat-developer/vscode-java/blob/master/formatters/eclipse-formatter.xml
                    -- url = "/home/local/.config/nvim/addons/java-format-styles.xml",
                    -- profile = "Default",
                }

            },
            configuration = {
                -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
                -- And search for `interface RuntimeOption`
                -- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
                runtimes = {
                    {
                        name = "JavaSE-21",
                        path = "/usr/lib/jvm/java-1.21.0-openjdk-amd64/",
                    },
                    {
                        name = "JavaSE-17",
                        path = "/usr/lib/jvm/java-1.17.0-openjdk-amd64/",
                    },
                    {
                        name = "JavaSE-1.8",
                        path = "/usr/lib/jvm/java-8-openjdk-amd64/",
                    },
                },

            }
        },
    },
    completion = {
        -- enabled = true,
        -- gueesMethodArgumetns = true,
        -- matchCase = 'FIRSTLETTER',
        -- enabled = true,
        -- maxResults = 1,
        -- postfix = { enabled = true },
        favoriteStaticMembers = {
            "org.hamcrest.MatcherAssert.assertThat",
            "org.hamcrest.Matchers.*",
            "org.hamcrest.CoreMatchers.*",
            "org.junit.jupiter.api.Assertions.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
            "org.mockito.Mockito.*",
            "java.util.Objects.*"
        },
    },
    -- Language server `initializationOptions`
    -- You need to extend the `bundles` with paths to jar files
    -- if you want to use additional eclipse.jdt.ls plugins.
    --
    -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
    --
    -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
    init_options = {
        bundles =
            vim.list_extend(
                Paths.java_test_plugins,
                { Paths.java_debug_plugin }
            ),
    },

    on_attach = function()
        jdtls.setup_dap({ hotcodereplace = 'auto' })
    end,
}


-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require('jdtls').start_or_attach(config)
require('jdtls').jol_path = vim.env.JOL_HOME
