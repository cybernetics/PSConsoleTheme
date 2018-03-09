# Get public and private functions
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# dot source files
foreach ($import in @($Public + $Private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

$manifest = Test-ModuleManifest (Join-Path $PSScriptRoot 'PSConsoleTheme.psd1') -WarningAction SilentlyContinue

# Create PSConsoleTheme object
$Script:PSConsoleTheme = @{}
$PSConsoleTheme.Version = $manifest.Version
$PSConsoleTheme.Themes = Get-Theme

# Import user configuration
$PSConsoleTheme.User = Import-UserConfiguration

# Export module functions
Export-ModuleMember -Function $Public.BaseName

# Debugging session exports
if ($null -ne ($session = $Global:PSConsoleThemeDebugSessionPath) -and $PSScriptRoot -eq $session) {
    Write-Warning "Module loaded in debugging mode from $session"
    $PSConsoleTheme.Debug = $true
    Export-ModuleMember -Variable 'PSConsoleTheme'
}