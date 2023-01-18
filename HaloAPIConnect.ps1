#------------Example: How to retrieve a Secret-----------
$TenantId = "17b3e2dc-8581-4b06-9ac5-53e0448a6742"
$ApplicationId = "0cc6174e-e7b0-45c5-aad9-4bed07a3dd3b"
$Thumbprint = (Get-ChildItem cert:\CurrentUser\My\ | Where-Object {$_.Subject -eq "CN=AdaptITKeyVault" }).Thumbprint
Connect-AzAccount -ServicePrincipal -CertificateThumbprint $Thumbprint -ApplicationId $ApplicationId -TenantId $TenantId
#------------End Example---------------------------------


#Setup Halo
$HaloClientID = Get-AzKeyVaultSecret -vaultName "AdaptITKeyVault" -name "#{HaloClientID}#" -AsPlainText
$HaloClientSecret = Get-AzKeyVaultSecret -vaultName "AdaptITKeyVault" -name "ProdHaloClientSecret" -AsPlainText
$HaloURL = "https://helpdesk.adapt-it.com"
$HaloTenant = "adaptit"

if (Get-Module -ListAvailable -Name HaloAPI) {
    Import-Module HaloAPI 
} else {
    Install-Module HaloAPI -Force
    Import-Module HaloAPI
}

Connect-HaloAPI -URL $HaloURL -ClientId $HaloClientID -ClientSecret $HaloClientSecret -Scopes "all" -Tenant $HaloTenant

