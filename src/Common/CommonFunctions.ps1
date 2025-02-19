# Common functions used across the toolkit

function Connect-PowerBIService {
    param (
        [Parameter(Mandatory=$false)]
        [string]$TenantId
    )
    
    try {
        if ($TenantId) {
            Connect-PowerBIServiceAccount -TenantId $TenantId
        } else {
            Connect-PowerBIServiceAccount
        }
    } catch {
        Write-Error "Failed to connect to Power BI service: $_"
        throw
    }
}

function Get-PowerBIAccessToken {
    try {
        $token = Get-PowerBIAccessToken
        return $token.AccessToken
    } catch {
        Write-Error "Failed to get access token: $_"
        throw
    }
}

function Update-DataSourceConnection {
    param (
        [Parameter(Mandatory=$true)]
        [string]$DatasetId,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$ConnectionDetails
    )
    
    try {
        $token = Get-PowerBIAccessToken
        
        $headers = @{
            'Content-Type' = 'application/json'
            'Authorization' = "Bearer $token"
        }
        
        $body = ConvertTo-Json $ConnectionDetails
        
        $uri = "https://api.powerbi.com/v1.0/myorg/datasets/$DatasetId/Default.UpdateDatasources"
        
        Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body $body
        
    } catch {
        Write-Error "Failed to update data source connection: $_"
        throw
    }
}

function Update-Parameters {
    param (
        [Parameter(Mandatory=$true)]
        [string]$DatasetId,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$Parameters
    )
    
    try {
        $token = Get-PowerBIAccessToken
        
        $headers = @{
            'Content-Type' = 'application/json'
            'Authorization' = "Bearer $token"
        }
        
        $body = ConvertTo-Json $Parameters
        
        $uri = "https://api.powerbi.com/v1.0/myorg/datasets/$DatasetId/Default.UpdateParameters"
        
        Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body $body
        
    } catch {
        Write-Error "Failed to update parameters: $_"
        throw
    }
}