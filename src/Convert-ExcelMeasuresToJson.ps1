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
    # Clean up the expression by properly handling DAX formatting
    $cleanExpression = $measure.EXPRESSION
    if ($cleanExpression) {
        # Convert Unicode escape sequences back to actual characters
        $cleanExpression = [Regex]::Unescape($cleanExpression)
        
        # Handle single quotes consistently
        $cleanExpression = $cleanExpression.Replace("'", "'")
        
        # Handle special characters
        $cleanExpression = $cleanExpression.Replace("\u003c", "<")
                                         .Replace("\u003e", ">")
                                         .Replace("\u0026\u0026", "&&")
                                         .Replace("\n", "`n")  # Preserve actual newlines
                                         .Replace("\t", "`t")  # Preserve actual tabs
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

# Final cleanup of any remaining escape sequences
$jsonString = [Regex]::Unescape($jsonString)

# Save the file with UTF8 encoding to properly handle special characters
[System.IO.File]::WriteAllText($OutputPath, $jsonString, [System.Text.Encoding]::UTF8)

Write-Host "Conversion complete. JSON file saved to: $OutputPath"