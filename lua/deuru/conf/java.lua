return function()
    -- setting up cmp capabilities for jdtls
    local jdtls = require('jdtls')
    local mason_registry = require('mason-registry')

    -- local mason_jdtls_path = mason_registry.get_package('jdtls'):get_install_path()
    local mason_jdtls_path = vim.fn.glob("~/jdtls")
    local java_debug_adapter = mason_registry
        .get_package("java-debug-adapter")
        :get_install_path()

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

    local extendedClientCapabilities = jdtls.extendedClientCapabilities
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



    jdtls.start_or_attach({
        cmd = {
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
            "-Xmx512m",
            "-Xms100m",

            "--add-modules=ALL-SYSTEM",
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",
            "-javaagent:" .. Paths.lombok,
            --
            "-jar", Paths.jdtls_launcher,
            "-configuration", Paths.jdtls .. "/config_linux",
            "-data", Paths.workspace_dir
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
                "com",
                "org",
                "java",
                "javax"
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
                    Paths.java_test_plugins,
                    { Paths.java_debug_plugin }
                ),
            extendedClientCapabilities = extendedClientCapabilities
        },
        capabilities =
        {
            workspace = {
                configuration = true
            },
            textDocument = {
                completion = {
                    completionItem = {
                        snippetSupport = true
                    }
                }
            }
        } -- jol_path = '/opt/jol/jol-cli-0.9-full.jar'
        -- require('cmp_nvim_lsp').default_capabilities()
    })
end
