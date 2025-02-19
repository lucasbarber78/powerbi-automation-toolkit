# Project initialization script

# Check prerequisites
function Test-Prerequisites {
    $modules = @('MicrosoftPowerBIMgmt')
    foreach ($module in $modules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Host "Installing $module..."
            Install-Module -Name $module -Scope CurrentUser -Force
        }
    }
}

# Create required directories
function Initialize-ProjectStructure {
    $dirs = @(
        'config',
        'templates',
        'output',
        'logs'
    )
    
    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir
            Write-Host "Created directory: $dir"
        }
    }
}

# Main initialization
Test-Prerequisites
Initialize-ProjectStructure