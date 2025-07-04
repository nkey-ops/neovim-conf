-- setting up cmp capabilities for jdtls
local jdtls = require('jdtls')

local mason_package_path = "/home/local/.local/share/nvim/mason/packages"
local mason_jdtls_path = mason_package_path .. "/jdtls"
local java_debug_adapter = mason_package_path .. "/java-debug-adapter"
local java_test = mason_package_path .. "/java-test"

assert(vim.fn.mkdir(vim.fn.glob("~") .. "/.cache/jdtls", 'p') == 1,
    "Couldn't create '~/.cache/jdtls' directory")

local Paths = {
    -- important to bea  function so the options can be applied to differnt
    -- projects, while not loading all of the configurations every time
    workspace_dir     = function()
        return vim.fn.glob('~/.cache/jdtls/')
            .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    end,
    jdtls             = mason_jdtls_path,
    jdtls_launcher    = vim.fn.glob(mason_jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
    java_debug_plugin = vim.fn.glob(java_debug_adapter .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"),
    java_test_plugins =
        vim.fn.glob(java_test .. "/extension/server/*.jar", true, true),
    lombok            = mason_jdtls_path .. "/lombok.jar",
}

local test_plugins = {}
for _, value in pairs(Paths.java_test_plugins) do
    if not (
            value:match(".+jacocoagent.+") or
            value:match(".+runner%-jar%-with%-dependencies.+")) then
        table.insert(test_plugins, value)
    end
end
Paths.java_test_plugins = test_plugins


-- local extendedClientCapabilities = jdtls.extendedClientCapabilities
-- extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

return function()
    return {
        cmd = {
            -- "java",
            "/usr/lib/jvm/java-21-openjdk-amd64/bin/java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "--add-modules=ALL-SYSTEM",
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",

            -- "-XX:+UseParallelGC",
            -- "-XX:GCTimeRatio=4",
            -- "-XX:AdaptiveSizePolicyWeight=90",
            -- "-Dsun.zip.disableMemoryMapping=true",
            -- "-Xms100m",
            -- "-Xmx512m",

            '-Xmx1000M',
            -- '-XX:ReservedCodeCacheSize=64m',
            -- '-XX:-UseCompressedClassPointers',
            -- "-Xss512k",
            -- "-XX:MaxRAM=500",

            "-javaagent:" .. Paths.lombok,
            "-jar", Paths.jdtls_launcher,
            "-configuration", Paths.jdtls .. "/config_linux",
            "-data", Paths.workspace_dir()
        },
        -- This is the default if not provided, you can remove it. Or adjust as needed.
        -- One dedicated LSP server & client will be started per unique root_dir
        root_dir = require('jdtls.setup').find_root({ 'gradlew', 'mvnw', '.git', 'pom.xml' }),
        settings = {
            java = {
                project = {},
                signatureHelp = {
                    enabled = true,
                    description = { enabled = true } -- not working
                },
                contentProvider = { preferred = 'fernflower' },
                import = { enabled = true },
                rename = { enabled = true },

                maven = {
                    downloadSources = true,
                },
                implementationsCodeLens = {
                    enabled = false,
                },
                referenceCodeLens = {
                    enabled = true,
                },
                references = {
                    includeAccessors = true,
                    includeDecompiledSources = true,
                },
                completion = {
                    enabled = true,
                    favoriteStaticMembers = {
                        "java.util.Objects.*",
                        "java.util.Arrays.*",
                        "org.hamcrest.MatcherAssert.assertThat",
                        "org.hamcrest.Matchers.*",
                        "org.hamcrest.CoreMatchers.*",
                        "org.mockito.Mockito.*",
                        "org.mockito.ArgumentMatchers.*",
                        "org.junit.Assert.*",
                        "org.junit.Assume.*",
                        "org.junit.jupiter.api.Assertions.*",
                        "org.junit.jupiter.api.Assumptions.*",
                        "org.junit.jupiter.api.DynamicContainer.*",
                        "org.junit.jupiter.api.DynamicTest.*",
                        "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
                        "org.springframework.test.web.servlet.result.MockMvcResultMatchers.*"
                    },
                    -- overwrite = true,
                    guessMethodArguments = true,
                    -- matchCase = "FIRSTLETTER", -- doesn't return @code
                    -- postFix = true,

                },
                codeGeneration = {
                    generateComments = true,
                    insertionLocation = "lastMember",
                    useBlocks = true,
                },
                format = {
                    enabled = true,
                },
                inlayhints = {
                    parameterNames = {
                        enabled = "all"
                    }
                },
                maxConcurrentBuilds = 1,
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
            bundles =
                vim.list_extend(
                    Paths.java_test_plugins,
                    { Paths.java_debug_plugin }
                ),

        },
        on_attach = function()
            jdtls.setup_dap({ hotcodereplace = 'auto' })
        end,
        capabilities = require('cmp_nvim_lsp').default_capabilities()
        --  jol_path = '/opt/jol/jol-cli-0.9-full.jar'

    }
end
