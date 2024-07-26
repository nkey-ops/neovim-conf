-- setting up cmp capabilities for jdtls
local jdtls = require('jdtls')
local mason_registry = require('mason-registry')

-- local mason_jdtls_path = mason_registry.get_package('jdtls'):get_install_path()
local mason_jdtls_path = vim.fn.glob("~/jdtls")
local java_debug_adapter = mason_registry
    .get_package("java-debug-adapter"):get_install_path()

local Paths = {
    workspace_dir     =
        vim.fn.glob('~/.cache/jdtls/') ..
        vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t'),
    jdtls             = mason_jdtls_path,
    jdtls_launcher    = vim.fn.glob(
        mason_jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),

    java_debug_plugin = vim.fn.glob(java_debug_adapter ..
        "/extension/server/com.microsoft.java.debug.plugin-*.jar"),
    java_test_plugins = vim.split(
        vim.fn.glob("~/.config/nvim/addons/vs-java-test/*.jar", true),
        "\n"),

    lombok            = mason_jdtls_path .. "/lombok.jar",
}



-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
    -- The command that starts the language server
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    cmd = {

        -- 💀
        -- 'java', -- or
        '/usr/lib/jvm/java-21-openjdk-amd64/bin/java',
        -- '/path/to/java17_or_newer/bin/java'
        -- depends on if `java` is in your $PATH env variable and if it points to the right version.

        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',

        '-Xmx600m',
        '-XX:ReservedCodeCacheSize=64m',
        '-XX:-UseCompressedClassPointers',
        '-Xss256k',

        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',


        "-javaagent:" .. Paths.lombok,
        -- 💀
        '-jar', Paths.jdtls_launcher,
        -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
        -- Must point to the                                                     Change this to
        -- eclipse.jdt.ls installation                                           the actual version


        -- 💀
        '-configuration', Paths.jdtls .. '/config_linux',
        -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
        -- Must point to the                      Change to one of `linux`, `win` or `mac`
        -- eclipse.jdt.ls installation            Depending on your system.


        -- 💀
        -- See `data directory configuration` section in the README
        '-data', Paths.workspace_dir
    },

    -- 💀
    -- This is the default if not provided, you can remove it. Or adjust as needed.
    -- One dedicated LSP server & client will be started per unique root_dir
    --
    -- vim.fs.root requires Neovim 0.10.
    -- If you're using an earlier version, use: require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),
    -- root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew" }),
    root_dir = jdtls.setup.find_root({ '.git', 'mvnw', 'gradlew' }),
    -- Here you can configure eclipse.jdt.ls specific settings
    -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    -- for a list of options
    settings = {
        java = {
            signatureHelp = { enabled = true },
            format = {
                enabled = true,
                settings = {
                    ---[1] https://github.com/redhat-developer/vscode-java/wiki/Formatter-settings
                    --  [2] https://github.com/redhat-developer/vscode-java/blob/master/formatters/eclipse-formatter.xml
                    url = "/home/local/.config/nvim/addons/java-format-styles.xml",
                    profile = "Default",
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
    end

}
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require('jdtls').start_or_attach(config)
