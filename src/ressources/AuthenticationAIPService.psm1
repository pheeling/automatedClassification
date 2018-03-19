class AuthenticationAIPService{

    [Object] $credentialsFile
    
    AuthenticationAIPService(){
        Import-Module AzureInformationProtection
        Import-module aadrm
    }

    setCredentialsFile([String] $credentialsFilePath){
        $this.credentialsFile =  Import-Clixml $credentialsFilePath;
    }

    createLoginCredentialFile(){
        Get-Credential | Export-Clixml -Path $PSScriptRoot\${env:USERNAME}_cred.xml
    }

    authenticateWithCredentialsFile(){

    try {
        [Reflection.Assembly]::LoadFile("C:\Windows\system32\WindowsPowerShell\v1.0\Modules\AADRM\Microsoft.IdentityModel.Clients.ActiveDirectory.dll")
        $clientId='e0dfc34c-7548-43d7-952b-8d4721b3f493';
        $resourceId = 'https://api.aadrm.com/';
        $userName= $this.credentialsFile.Username;
        $password= $this.credentialsFile.Password;
        $redirectUri = new-object System.Uri("https://aadrm.com/AADRMAdminPowershell");
        $authority = "https://login.microsoftonline.com/common";
        $authContext = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext($authority);
        $userCreds = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.UserCredential($userName, $password);
        $authenticationResult = $authContext.AcquireToken($resourceId,$clientId,$userCreds);
        Connect-Aadrmservice -AccessToken $authenticationResult.AccessToken
    } catch {
        Write-Host "Failed"
    }

    }

}