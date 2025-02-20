# Import the ImportExcel module if not already installed
# Install-Module -Name ImportExcel -Scope CurrentUser

# Script to convert Excel measures to JSON format
param(
    [Parameter(Mandatory=$true)]
    [string]$ExcelPath,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputPath
)

# Import Excel data
$measures = Import-Excel -Path $ExcelPath

# Create measures array
$measureArray = @()

foreach ($measure in $measures) {
    $measureObject = @{
        name = $measure.MEASURE_NAME
        table = $measure.MEASUREGROUP_NAME
        expression = $measure.EXPRESSION
        description = if ($measure.DESCRIPTION) { $measure.DESCRIPTION } else { "" }
        formatString = if ($measure.DEFAULT_FORMAT_STRING) { $measure.DEFAULT_FORMAT_STRING } else { "#,##0.00" }
        displayFolder = if ($measure.MEASURE_DISPLAY_FOLDER) { $measure.MEASURE_DISPLAY_FOLDER } else { "General" }
    }
    
    $measureArray += $measureObject
}

# Create final JSON structure
$jsonStructure = @{
    measures = $measureArray
}

# Convert to JSON and save
$jsonStructure | ConvertTo-Json -Depth 10 | Set-Content $OutputPath

Write-Host "Conversion complete. JSON file saved to: $OutputPath"