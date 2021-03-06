function Get-NewErrorHandling($errorSubject, $errorBody){
    return [ErrorHandling]::new($errorSubject, $errorBody)
}
function Get-NewErrorHandling($errorSubject){
    return [ErrorHandling]::new($errorSubject)
}

class ErrorHandling {

    [String] $recipient = "helpdesk@dinotronic.ch"
    [String] $sender = "tech@dinotronic.ch"
    [String] $smtpSender = "smtp.hostedbusiness.ch"
    [String] $errorSubject
    $errorBody 

    ErrorHandling([String] $errorSubject, $errorBody){
        $this.errorSubject = $errorSubject
        $this.errorBody = $errorBody
        $this.sendMailwithErrorMsgWithLastErrorContent()
    }

    ErrorHandling([String] $errorSubject){
        $this.errorSubject = $errorSubject
    }

    sendMailwithErrorMsgWithLastErrorContent(){
        $body += "<h2>DT CSP Data Sync Service Error</h2>"
        $body += "<h3>Details:</h3>"
        $body += "<ul>"
        $body += $this.errorBody.ToString()
        $body += "</ul>"
        Send-MailMessage -To $this.recipient -From $this.sender -Subject `
        $this.errorSubject -BodyAsHtml $body -SmtpServer $this.smtpSender
    }

    sendMailwithInformMsgContent($errorBody){
        $body += "<h2>DZ: Error Report Automatic AIP Classification</h2>"
        $body += "<h3>Details:</h3>"
        $body += "<ul>"
        $body += $errorBody
        $body += "</ul>"
        Send-MailMessage -To $this.recipient -From $this.sender -Subject `
        $this.errorSubject -BodyAsHtml $body -SmtpServer $this.smtpSender
    }
}
