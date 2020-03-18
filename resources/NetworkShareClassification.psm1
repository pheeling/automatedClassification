function Get-NetworkShareClassification($tenantID){
    return [NetworkShareClassification]::new($tenantID)
}

class NetworkShareClassification{

    [String] $tenantID
    [String] $svcCredentialFilepath = "$Global:resourcespath\${env:USERNAME}_svcCred_$($tenantID).xml"
    [PSCredential] $svcCredentials

    NetworkShareClassification($tenantID){
        $this.tenantID = $tenantID
    }

    connectAIPService([String] $webAppID, [String] $webAppKey, [string] $dataOwner){
        if (!(Test-Path $this.svcCredentialFilepath)) {
            Get-Credential | Export-Clixml -Path $this.svcCredentialFilepath
            $this.svcCredentials = Import-Clixml $this.svcCredentialFilepath
            Write-Error "If your running this script the first time, please run Set-AIPAuthentication with elevated Privileges, 
            Set-AIPAuthentication -AppId $webAppID -AppSecret $webAppKey -TenantId $this.tenantID -DelegatedUser $this.sharepointCredentials.UserName -OnBehalfOf $this.svcCredentials"
            Set-AIPAuthentication -AppId $webAppID -AppSecret $webAppKey -TenantId $this.tenantID -DelegatedUser $dataOwner -OnBehalfOf $this.svcCredentials
            Exit 1
        } else {
            "$(Get-Date) [Processing] Set-AIPAuthentication already run" >> $Global:logFile
        }
    }

    [string[]] readNetworkShareListFile($networkShareList){
        return Get-Content -Path $networkShareList
    }

    fileClassification($networkShareArray, $labelId, $dataOwner){
        Get-ChildItem $networkShareArray -Recurse | 
        Where-Object {".docx",".xlsx",".pptx",".pdf" -eq $_.extension} | 
        Select-Object -ExpandProperty Fullname | 
        Get-AIPFileStatus | 
        Where-Object {$_.IsLabeled -eq $False} |
        Set-AIPFileLabel -LabelId $labelId -Owner $dataOwner -PreserveFileDetails | 
        Export-Csv -Append $Global:AIPStatusFile
    }

    fileRetention($filepath){
        if ((Get-ChildItem -path $filepath).Length -gt 5242880) {
            Remove-Item -Path $filepath
        }
    }
}
