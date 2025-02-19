# Template update and deployment script

. "$PSScriptRoot\Common\CommonFunctions.ps1"

function Update-PowerBITemplate {
    param (
        [Parameter(Mandatory=$true)]
        [string]$TemplatePath,
        
        [Parameter(Mandatory=$true)]
        [string]$ConfigPath,
        
        [Parameter(Mandatory=$false)]
        [switch]$ValidateOnly
    )
    
    try {
        # Load configurations
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        
        # Validate template exists
        if (-not (Test-Path $TemplatePath)) {
            throw "Template file not found: $TemplatePath"
        }
        
        # Connect to Power BI service
        Connect-PowerBIService
        
        foreach ($client in $config.clients) {
            Write-Host "Processing client: $($client.name)"
            
            # Create output filename
            $outputFile = Join-Path $config.templateSettings.outputPath "$($client.clientId)_report.pbix"
            
            # Copy template to output
            Copy-Item -Path $TemplatePath -Destination $outputFile -Force
            
            if (-not $ValidateOnly) {
                # Update connection details
                $connectionDetails = @{
                    "server" = $client.databaseServer
                    "database" = $client.databaseName
                }
                
                Update-DataSourceConnection -DatasetId $client.datasetId -ConnectionDetails $connectionDetails
                
                # Update parameters
                if ($client.parameters) {
                    Update-Parameters -DatasetId $client.datasetId -Parameters $client.parameters
                }
                
                Write-Host "Updated template for $($client.name)"
            }
        }
        
    } catch {
        Write-Error "Error updating template: $_"
        throw
    }
}

function New-ClientDeployment {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ClientName,
        
        [Parameter(Mandatory=$true)]
        [string]$DatabaseServer,
        
        [Parameter(Mandatory=$true)]
        [string]$DatabaseName,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$Parameters
    )
    
    try {
        # Generate new client ID
        $clientId = "CLIENT_" + [System.Guid]::NewGuid().ToString("N").Substring(0, 8)
        
        # Create client config
        $clientConfig = @{
            clientId = $clientId
            name = $ClientName
            databaseServer = $DatabaseServer
            databaseName = $DatabaseName
            parameters = $Parameters
        }
        
        # Load existing config
        $configPath = Join-Path $PSScriptRoot "..\config\clients.json"
        $config = Get-Content $configPath | ConvertFrom-Json
        
        # Add new client
        $config.clients += $clientConfig
        
        # Save updated config
        $config | ConvertTo-Json -Depth 10 | Set-Content $configPath
        
        Write-Host "Added new client configuration: $ClientName"
        
        # Deploy template for new client
        Update-PowerBITemplate -TemplatePath (Join-Path $PSScriptRoot "..\templates\base-template.pbit") -ConfigPath $configPath
        
    } catch {
        Write-Error "Error creating new client deployment: $_"
        throw
    }
}