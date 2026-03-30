# Abort on any error — prevents partial/empty output being committed
$ErrorActionPreference = 'Stop'

# Ensure Az.Resources is up-to-date; installs if missing, updates if outdated, no-ops if current
Install-PSResource Az.Resources -Scope CurrentUser -Quiet -AcceptLicense -TrustRepository

# Get all available policy aliases
$resourceTypes = Get-AzPolicyAlias -ListAvailable
$providers = $resourceTypes | Group-Object -Property Namespace

$basePath = "aliases"

# Wipe and recreate to remove stale files from deleted/renamed resource types
if (Test-Path -Path $basePath) {
    Remove-Item -Path $basePath -Recurse -Force
}
New-Item -Name $basePath -ItemType "directory" | Out-Null

# Use StringBuilder to avoid O(n^2) string allocations from repeated +=
$toc = [System.Text.StringBuilder]::new()
[void]$toc.AppendLine(@"
# 📋 Azure Policy Aliases
![Update Aliases](https://github.com/jeircul/azure-policy-aliases/actions/workflows/update-aliases.yml/badge.svg)

🎯 This repository contains all available resource property aliases for easy reference when creating Policy definitions.

📅 The data is periodically fetched using ``Get-AzPolicyAlias`` command provided as part of the Az Module.

✨ **Total Providers**: $($providers.Count) | 📦 **Resource Types**: $($resourceTypes.Count)

---
"@)

foreach ($provider in $providers) {
    $resourceTypesWithAliases = $provider.Group | Where-Object { $_.Aliases.Count -gt 0 }

    if ($resourceTypesWithAliases.Count -gt 0) {
        [void]$toc.AppendLine("## 🔷 $($provider.Name)")
        [void]$toc.AppendLine()

        $namespacePath = Join-Path -Path $basePath -ChildPath $provider.Name

        if (!(Test-Path -Path $namespacePath)) {
            New-Item -Path $namespacePath -ItemType "directory" | Out-Null
        }

        foreach ($resourceType in $resourceTypesWithAliases) {
            $sb = [System.Text.StringBuilder]::new()
            [void]$sb.AppendLine("# $($resourceType.Namespace)/$($resourceType.ResourceType)")
            [void]$sb.AppendLine()
            [void]$sb.AppendLine("| Default Path | Alias |")
            [void]$sb.AppendLine("|---|---|")

            foreach ($alias in $resourceType.Aliases) {
                [void]$sb.AppendLine("| ``$($alias.DefaultPath)`` | ``$($alias.Name)`` |")
            }

            $fileName = $resourceType.ResourceType.Replace("/", "-")
            $filePath = Join-Path -Path $namespacePath -ChildPath "$($fileName).md"

            # Direct .NET write is significantly faster than the Out-File pipeline
            [System.IO.File]::WriteAllText($filePath, $sb.ToString(), [System.Text.Encoding]::UTF8)

            [void]$toc.AppendLine("- [$($resourceType.Namespace)/$($resourceType.ResourceType)]($filePath)")
        }

        [void]$toc.AppendLine()
    }
}

[System.IO.File]::WriteAllText("README.md", $toc.ToString(), [System.Text.Encoding]::UTF8)
