# DAX Measure Management Script
. "$PSScriptRoot\Common\CommonFunctions.ps1"

function Import-DAXMeasures {
    param (
        [Parameter(Mandatory=$true)]
        [string]$MeasuresPath,
        
        [Parameter(Mandatory=$true)]
        [string]$DatasetId
    )
    
    try {
        # Read measures from JSON file
        $measures = Get-Content $MeasuresPath | ConvertFrom-Json
        
        # Connect to Power BI service
        Connect-PowerBIService
        
        # Get access token
        $token = Get-PowerBIAccessToken
        
        foreach ($measure in $measures) {
            Write-Host "Processing measure: $($measure.name)"
            
            $headers = @{
                'Content-Type' = 'application/json'
                'Authorization' = "Bearer $token"
            }
            
            # XMLA endpoint URL for creating/updating measures
            $uri = "https://api.powerbi.com/v1.0/myorg/datasets/$DatasetId/executeQueries"
            
            $dax = @"
            {
                "createOrReplace": {
                    "object": {
                        "database": "$($measure.database)",
                        "table": "$($measure.table)",
                        "measure": {
                            "name": "$($measure.name)",
                            "expression": "$($measure.expression)"
                        }
                    }
                }
            }
"@
            
            Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body $dax
            Write-Host "Successfully created/updated measure: $($measure.name)"
        }
        
    } catch {
        Write-Error "Error importing DAX measures: $_"
        throw
    }
}

function Export-DAXMeasures {
    param (
        [Parameter(Mandatory=$true)]
        [string]$DatasetId,
        
        [Parameter(Mandatory=$true)]
        [string]$OutputPath
    )
    
    try {
        # Connect to Power BI service
        Connect-PowerBIService
        
        # Get access token
        $token = Get-PowerBIAccessToken
        
        $headers = @{
            'Content-Type' = 'application/json'
            'Authorization' = "Bearer $token"
        }
        
        # Get dataset metadata
        $uri = "https://api.powerbi.com/v1.0/myorg/datasets/$DatasetId"
        $dataset = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers
        
        # Get all measures
        $measuresQuery = "SELECT MEASURE_NAME, MEASURE_EXPRESSION FROM $($dataset.name).TMSCHEMA_MEASURES"
        $measures = Invoke-PowerBIRestMethod -Url $uri -Method POST -Body $measuresQuery
        
        # Convert to JSON and save
        $measures | ConvertTo-Json -Depth 10 | Set-Content $OutputPath
        Write-Host "Successfully exported measures to: $OutputPath"
        
    } catch {
        Write-Error "Error exporting DAX measures: $_"
        throw
    }
}

function Update-DAXMeasuresAcrossClients {
    param (
        [Parameter(Mandatory=$true)]
        [string]$MeasuresPath,
        
        [Parameter(Mandatory=$true)]
        [string]$ConfigPath
    )
    
    try {
        # Load client configurations
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        
        foreach ($client in $config.clients) {
            Write-Host "Updating measures for client: $($client.name)"
            Import-DAXMeasures -MeasuresPath $MeasuresPath -DatasetId $client.datasetId
        }
        
    } catch {
        Write-Error "Error updating measures across clients: $_"
        throw
    }
}