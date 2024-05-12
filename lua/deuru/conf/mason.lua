local mason_registry = require("mason-registry")
local Package = require("mason-core.package")

local packages =
{
    "checkstyle",
    "google-java-format",
    "sql-formatter",
    "java-debug-adapter",
    "java-test",
    -- "trivy",
}

print("lsp.lua: Enshuring all the Mason packages are installed...")
for _, package_name in ipairs(packages) do
    if not mason_registry.is_installed(package_name) then
        print("Not Installed", package_name)
        local package = mason_registry.get_package(package_name)
        Package.install(package, {})
        print("Added to Installention queue", package_name)
    else
        print("Installed", package_name)
    end
end
print()
