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
    # Clean up the expression by removing escape sequences
    $cleanExpression = $measure.EXPRESSION
    if ($cleanExpression) {
        $cleanExpression = $cleanExpression.Replace("\n", " ").Replace("\t", " ")
        # Remove multiple spaces
        $cleanExpression = [System.Text.RegularExpressions.Regex]::Replace($cleanExpression, "\s+", " ")
    }

    $measureObject = @{
        name = $measure.MEASURE_NAME
        table = $measure.MEASUREGROUP_NAME
        expression = $cleanExpression
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

# Convert to JSON and save with proper formatting
$jsonString = $jsonStructure | ConvertTo-Json -Depth 10
# Clean up any remaining escape sequences in the final JSON
$jsonString = $jsonString.Replace("\n", " ").Replace("\t", " ")
$jsonString | Set-Content $OutputPath

Write-Host "Conversion complete. JSON file saved to: $OutputPath"