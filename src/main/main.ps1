############################################
# Title: Automated AIP Classification
#
# Author: Philipp Hiestand
# Version: 23-02-2018
#
# Description: 
# Could be executed as Scheduled Task under a privilege user to automate 
# Azure Information Protection
#
# Requirement: User in Credentials File need to be added to AadrmRoleBases Administrators as GlobalAdministrator
# Connect-AadrmService
# Add-AadrmRoleBasedAdministrator -EmailAddress $authentication.credentialsFile.Username -Role GlobalAdministrator
#
#
############################################

Using Module "C:\Datastore\Dinotronic\_Interne Projekt\_AzIP_DT\automatedClassification\src\ressources\AuthenticationAIPService.psm1"
Using Module "C:\Datastore\Dinotronic\_Interne Projekt\_AzIP_DT\automatedClassification\src\ressources\LabelFactory.psm1"

Write-Host "Programm executed"

[AuthenticationAIPService] $authentication = [AuthenticationAIPService]::new()
$authentication.setCredentialsFile("C:\Datastore\Dinotronic\_Interne Projekt\_AzIP_DT\automatedClassification\src\ressources\phili_cred.xml")
$authentication.authenticateWithCredentialsFile()

$labels = [LabelFactory]::getInstance()

$labels.setLabels()


<#
Import-Module AzureInformationProtection

Get-AadrmTemplate


[Policy] $Policy1 = [Policy]::new("policy", "1-0")
$Policy1 | Get-Member

[System.GC]::GetTotalMemory(‘forcefullcollection’) | out-null
#>