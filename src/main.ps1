Param(
    [Parameter(Mandatory=$true, HelpMessage = "Please enter DataOwner as UPN")]
    [String]$dataOwner,

    [Parameter(Mandatory=$true, HelpMessage = "Please enter Customer Tenant ID")]
    [String]$tenantID,

    [Parameter(Mandatory=$true, HelpMessage = "Which LabelID should be used for classification?")]
    [String]$labelId,

    [Parameter(Mandatory=$true, HelpMessage = "Define WebApp ID for connection?")]
    [String]$webAppID,

    [Parameter(Mandatory=$false, HelpMessage = "Define WebApp ID for connection?")]
    [String]$webAppKeyXMLFile, 

    [Parameter(Mandatory=$true, HelpMessage = "Define Path to NetworkShare List Text File?")]
    [String]$networkShareList,

    [Parameter(Mandatory=$true, HelpMessage = "Send Grid API Key?")]
    [String]$sendGridApiKey    
)

$Global:srcPath = split-path -path $MyInvocation.MyCommand.Definition 
$Global:mainPath = split-path -path $Global:srcPath
$Global:resourcespath = join-path -path "$Global:mainPath" -ChildPath "resources"
$Global:errorVariable = "Stop"
$Global:logFile = "$resourcespath\processing.log"
$Global:AIPStatusFile = "$resourcespath\$(get-date -Format yyyyMMdd_HHMMss)_AIPStatus.log"

Import-Module -Force "$resourcespath\ErrorHandling.psm1"
Import-Module -Force "$resourcespath\NetworkShareClassification.psm1"
Import-Module -Force "$resourcespath\SendGridMailMessage.psm1"

"$(Get-Date) [Processing] Start--------------------------" >> $Global:logFile

#Load EmailFunction
$sendGrid = Get-SendGridMailMessage $sendGridApiKey

#Requirements Check
try {
    if(Get-Command Get-AIPFileStatus -ErrorAction SilentlyContinue){
        "$(Get-Date) [RequirementsCheck] Module AIP exists" >> $Global:logFile
    }
    while(!($webAppKeyXMLFile)){
        $webAppKeyXMLFile = "$Global:resourcespath\${env:USERNAME}_webAppAPIKey_$($tenantID).xml"
        if(!(Test-Path $webAppKeyXMLFile)){
            $webAppKeyXMLFile = "$Global:resourcespath\${env:USERNAME}_webAppAPIKey_$($tenantID).xml"
            Get-Credential | Export-Clixml -Path $webAppKeyXMLFile
        } else {
            "$(Get-Date) [RequirementsCheck] token exists" >> $Global:logFile
        }
        $webAppKeyXML = Import-Clixml $webAppKeyXMLFile
    }
} catch {
    "$(Get-Date) [RequirementsCheck] Module installation failed: $PSItem" >> $Global:logFile
    #Get-NewErrorHandling "$(Get-Date) [RequirementsCheck] Module installation failed" $PSItem
}
$networkClassification = Get-NetworkShareClassification($tenantID)
$networkClassification.connectAIPService($webAppID,$webAppKeyXML.GetNetworkCredential().Password, $dataOwner)
$networkShareArray = $networkClassification.readNetworkShareListFile($networkShareList)
$networkClassification.fileClassification($networkShareArray, $labelId, $dataOwner)

if ($networkClassification.errorBody -ne $null){
    $sendGrid.setMailValues("servicedesk@dinotronic.ch","DZ: AIP Classification Error","$($networkClassification.errorBody)")
    $sendGrid.sendMailMessage()
}

"$(Get-Date) [Processing] Stopped -----------------------" >> $Global:logFile

$networkClassification.fileRetention($Global:resourcespath)
