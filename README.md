# Introduction 
Used to classify Data on a filer with AIP.

# Getting Started
1. Download Repo to executing server.
2. Create App Registration and Certification for Set-AIPAuthentication
https://docs.microsoft.com/en-us/azure/information-protection/rms-client/clientv2-admin-guide-powershell#how-to-label-files-non-interactively-for-azure-information-protection
3. $pscreds = get-credentials -user CLOUD\DZ_svc_Classificatio
Set-AIPAuthentication -AppId 32a3e80b-6e53-4579-ab9e-e0b260000f0f  -AppSecret blabla -TenantId cfce8a94-6ea4-4c5e-835a-4552900528f5 -DelegatedUser admin@drahtzugzh.onmicrosoft.com -OnBehalfOf $pscred 

# Build and Test
TODO: Describe and show how to build your code and run the tests. 

# Contribute / Example
This is an example how to interface between different API's and how to use Partner Center to integration into different platforms. Clone this example and create your own repo.