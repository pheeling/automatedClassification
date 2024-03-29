function Get-NetworkShareClassification($tenantID){
    return [NetworkShareClassification]::new($tenantID)
}

class NetworkShareClassification{

    [String] $tenantID
    [String] $svcCredentialFilepath = "$Global:resourcespath\admphiestand_svcCred_$($tenantID).xml"
    [PSCredential] $svcCredentials
    $errorBody = [System.Collections.ArrayList]::New()


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

    fileClassification($networkShareArray, $labelId, $dataOwner) {
        $results = @()
        $failed = @()
        $AIPFileStatusError = New-Object System.Object
        try {
            foreach ($item in $networkShareArray){
                $results += Get-ChildItem $item -Recurse | 
                Where-Object {".docx",".docm",".xlsx",".xlsm",".pptx",".pptm",".pdf" -eq $_.extension} | 
                Select-Object -ExpandProperty Fullname | 
                Get-AIPFileStatus -ErrorAction SilentlyContinue -ErrorVariable AIPFileStatusError | 
                #Where-Object {$_.IsLabeled -eq $False} |
                Select-Object -ExpandProperty FileName |
                Set-AIPFileLabel -LabelId $labelId -Owner $dataOwner -PreserveFileDetails
                if((($AIPFileStatusError.GetType()).name -ne "Object") -and (-not [string]::IsNullOrEmpty($AIPFileStatusError))){
                    foreach ($entry in $AIPFileStatusError){
                        "$(Get-Date) [FileClassification] File Classification failed: $($entry.TargetObject):: Status: $($entry.ToString())" >> $Global:logFile
                        #Debugging may produce to much noise
                        #$this.errorBody += @("<br>")
                        #$this.errorBody += @("<li>Name: $($entry.TargetObject)</li>")
                        #$this.errorBody += @("<li>Status: $($entry.CategoryInfo.Reason)</li>")
                        #$this.errorBody += @("<li>Comment: $($entry.ToString())</li>")
                    }
                }
            }
        } catch {
            "$(Get-Date) [FileClassification] File Classification failed: $PSItem" >> $Global:logFile
            #Get-NewErrorHandling "$(Get-Date) [RequirementsCheck] Module installation failed" $PSItem
        }
        foreach ($entry in $results){
            $entry | Export-Csv -Append $Global:AIPStatusFile
            if($entry.status -eq "Failed"){
                $this.errorBody += @("<br>")
                $this.errorBody += @("<li>Name: $($entry.Filename)</li>")
                $this.errorBody += @("<li>Status: $($entry.Status)</li>")
                $this.errorBody += @("<li>Comment: $($entry.Comment)</li>")
            }
        }
    }

    fileRetention($inputFolder){
        try{
            foreach ($file in (get-childitem -path $inputFolder | Where-Object {$_.lastwritetime -lt ( (get-date).adddays(-30)) -and $_.Name -like "*.log"} )) {
                "$(Get-Date) [Retention]  Purging old inputfile:: $file" >> $Global:logFile 
                Remove-item -path $file.Fullname
            }
        } catch {
            "$(Get-Date) [Retention] $PSitem error with File retention" >> $Global:logFile
        }
    }
}