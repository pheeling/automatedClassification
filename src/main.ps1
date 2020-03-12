Param(
    [Parameter(Mandatory=$true, HelpMessage = "Please enter DataOwner as UPN")]
    [String]$dataOwner,

    [Parameter(Mandatory=$true, HelpMessage = "Please enter Customer Tenant ID")]
    [String]$tenantID,

    [Parameter(Mandatory=$true, HelpMessage = "Which LabelID should be used for classification?")]
    [String]$labelId,

    [Parameter(Mandatory=$true, HelpMessage = "Define WebApp ID for connection?")]
    [String]$webAppID,

    [Parameter(Mandatory=$true, HelpMessage = "Define Path to NetworkShare List Text File?")]
    [String]$networkShareList
)

$Global:srcPath = split-path -path $MyInvocation.MyCommand.Definition 
$Global:mainPath = split-path -path $srcPath
$Global:resourcespath = join-path -path "$mainPath" -ChildPath "resources"
$Global:errorVariable = "Stop"
$Global:logFile = "$resourcespath\processing.log"
$Global:AIPStatusFile = "$resourcespath\AIPStatus.log"

Import-Module -Force "$resourcespath\ErrorHandling.psm1"
Import-Module -Force "$resourcespath\NetworkShareClassification.psm1"

"$(Get-Date) [Processing] Start--------------------------" >> $Global:logFile

#Requirements Check
try {
    if(Get-Command Get-AIPFileStatus -ErrorAction SilentlyContinue){
        "$(Get-Date) [RequirementsCheck] Module AIP exists" >> $Global:logFile
    }
    if(!(Test-Path $webAppKeyXMLFile)){
        Get-Credential | Export-Clixml -Path $webAppKeyXMLFile
    } else {
        "$(Get-Date) [RequirementsCheck] token exists" >> $Global:logFile
        $webAppKeyXML = Import-Clixml $webAppKeyXMLFile
    }
} catch {
    "$(Get-Date) [RequirementsCheck] Module installation failed: $PSItem" >> $Global:logFile
    #Get-NewErrorHandling "$(Get-Date) [RequirementsCheck] Module installation failed" $PSItem
}
$networkClassification = Get-NetworkShareClassification($tenantID)
$networkClassification.connectAIPService($webAppID,$webAppKeyXML.GetNetworkCredential().Password)
$networkShareArray = $networkClassification.readNetworkShareListFile($networkShareList)
$networkClassification.fileClassification($networkShareArray, $labelId, $dataOwner)

"$(Get-Date) [Processing] Stopped -----------------------" >> $Global:logFile

$sharepoint.fileRetention($Global:logfile)
$sharepoint.fileRetention($Global:AIPStatusFile)