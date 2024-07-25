# Check if Az.Resources module is installed, if not, install it
if (-not (Get-Module Az.Resources -ListAvailable)) {
    Install-Module Az.Resources -Force
}

# Get all available policy aliases
$resourceTypes = Get-AzPolicyAlias -ListAvailable

# Group resource types by namespace
$providers = $resourceTypes | Group-Object -Property Namespace

# Define base path
$basePath = "aliases"

# Create base directory if it doesn't exist
if (!(Test-Path -Path $basePath)) {
    New-Item -Name $basePath -ItemType "directory" | Out-Null
}

# Initialize table of contents
$toc = @"
# Azure Policy Aliases
![Finance](https://github.com/jeircul/azure-policy-aliases/actions/workflows/update-aliases.yml/badge.svg)

This repository contains all available resource property aliases for easy reference when creating Policy definitions.
The data is periodically fetched using Get-AzPolicyAlias command provided as part of the Az Module.

"@

# Loop through each provider
foreach ($provider in $providers) {
    $resourceTypesWithAliases = $provider.Group | Where-Object { $_.Aliases.Count -gt 0 }

    if ($resourceTypesWithAliases.Count -gt 0) {
        $toc += "## $($provider.Name)`n`n"

        $namespacePath = Join-Path -Path $basePath -ChildPath $provider.Name

        # Create namespace directory if it doesn't exist
        if (!(Test-Path -Path $namespacePath)) {
            New-Item -Path $namespacePath -ItemType "directory" | Out-Null
        }

        # Loop through each resource type with aliases
        foreach ($resourceType in $resourceTypesWithAliases) {
            $resourceMarkdown = "# $($resourceType.Namespace)/$($resourceType.ResourceType)`n`n"
            $resourceMarkdown += "| Default Path | Alias |`n|---|---|`n"

            # Loop through each alias
            foreach ($alias in $resourceType.Aliases) {
                $resourceMarkdown += "| ``$($alias.DefaultPath)`` | ``$($alias.Name)`` |`n"
            }

            $fileName = $resourceType.ResourceType.Replace("/", "-")
            $filePath = Join-Path -Path $namespacePath -ChildPath "$($fileName).md"

            # Write resource markdown to file
            $resourceMarkdown | Out-File -FilePath $filePath

            $toc += "- [$($resourceType.Namespace)/$($resourceType.ResourceType)]($filePath)`n"
        }

        $toc += "`n`n"
    }
}

# Write table of contents to README.md
$toc | Out-File -FilePath "README.md"
