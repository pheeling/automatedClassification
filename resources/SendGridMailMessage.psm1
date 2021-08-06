function Get-SendGridMailMessage($apikey){
    return [SendGridMailMessage]::GetInstance([String] $apikey)
}

class SendGridMailMessage {

    static [SendGridMailMessage] $instance
    $sendGridApiKey
    $mailValues 
    $errorBody = [System.Collections.ArrayList]::New()

    static [SendGridMailMessage] GetInstance($apikey){
        if ([SendGridMailMessage]::instance -eq $null) { 
            [SendGridMailMessage]::instance = [SendGridMailMessage]::new([String]$apikey)}
          return [SendGridMailMessage]::instance
    }

    SendGridMailMessage ($apikey){
        $secureApiKey = ConvertTo-SecureString $apikey -AsPlainText -Force
        $this.sendGridApiKey = New-Object System.Management.Automation.PSCredential ("X",$secureApiKey)
    }

    setMailValues($to, $subject, $body){
        $this.mailValues = @{
            personalizations = @(
                @{
                    to =  @(
                        @{
                            "email" = $to
                            "name"  = $to
                        }
                    )
                }
            )
            from = @{
                "email" = "tech@dinotronic.ch"
                "name"  = "tech@dinotronic.ch"           
            }
            reply_to = @{
                "email" = "tech@dinotronic.ch"
                "name"  = "tech@dinotronic.ch"
            }
            subject = $subject
            content = @(
                @{
                    "type" = "text/html"
                    "value" = $($body -join "`r`n")
                }
            )
        }
    }

    [PSCustomObject] convertContentToObject($response){
        $this.validation($response)
        return $response.Content | ConvertFrom-Json
    }

    [Array] sendMailMessage(){
        $url = "https://api.sendgrid.com/v3/mail/send"
        #$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}" -f $this.sendGridApiKey.GetNetworkCredential().Password)))
        $base64AuthInfo = $this.sendGridApiKey.GetNetworkCredential().Password
        $headers = @{Authorization="Bearer $($base64AuthInfo)"}
        $json = $this.mailValues | ConvertTo-Json -Depth 10
        return $this.convertContentToObject((Invoke-WebRequest -Uri $url -Headers $headers -ContentType "application/json" -Method "POST" -Body ([System.Text.Encoding]::UTF8.GetBytes($json)) <#-SkipHttpErrorCheck#> -UseBasicParsing))
    }

    validation($value){
        if ($value.StatusCode -ne 202){
            $date = "$(Get-Date)"
            "$(Get-Date) [Warning] .......................::::::::::::::::" | Add-Content -Path $Global:logFile
            "$(Get-Date) [Warning] $($value.StatusCode)" | Add-Content -Path $Global:logFile
            "$(Get-Date) [Warning] $($value.StatusDescription)" | Add-Content -Path $Global:logFile
            "$(Get-Date) [Warning] .......................::::::::::::::::" | Add-Content -Path $Global:logFile
            $this.errorBody += @("<br>")
            $this.errorBody += @("<li>$(Get-Date) $($value.StatusCode), $($value.StatusDescription)</li>")
            $logLines = Get-content -Path $Global:logFile | select-string -Pattern "$date" -context 10
            foreach ($line in $logLines.Context.PreContext){
                $this.errorBody += "$line<br>"
            }
            $this.errorBody += @("<b>$($logLines.line)</b>")
            foreach ($line in $logLines.Context.PostContext){
                $this.errorBody += "$line<br>"
            }
        }
    }
}