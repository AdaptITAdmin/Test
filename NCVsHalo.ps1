# Declare param with date, time and itegrity check 
param ($DateString, $CheckDesc, $CheckInterface, $CheckType)
Write-Host "outputting Check type $($CheckInterface) on the interface $($CheckDesc) to Azure Table with dates $($DateString)"

# Setup Halo
$HaloClientID = Get-AzKeyVaultSecret -vaultName "AdaptITKeyVault" -name "TestHaloClientID" -AsPlainText
$HaloClientSecret = Get-AzKeyVaultSecret -vaultName "AdaptITKeyVault" -name "TestHaloClientSecret" -AsPlainText
$HaloURL = Get-AzKeyVaultSecret -vaultName "AdaptITKeyVault" -name "TestHaloURL" -AsPlainText
$HaloTenant = Get-AzKeyVaultSecret -vaultName "AdaptITKeyVault" -name "TestHaloTenant" -AsPlainText

if (Get-Module -ListAvailable -Name HaloAPI) {
    Import-Module HaloAPI 
}
else {
    Install-Module HaloAPI -Force 
    Import-Module HaloAPI
}

Connect-HaloAPI -URL $HaloURL -ClientId $HaloClientID -ClientSecret $HaloClientSecret -Scopes "all" -Tenant $HaloTenant

# Enter table storage location data
$StorageAccName = "mainadaptstorage"
$TableName = "IntegrityChecksLogs"

# SAS Token will last for 3 years
$SASToken = "?sv=2021-06-08&ss=t&srt=sco&sp=rwdlacu&se=2026-02-07T00:16:24Z&st=2023-02-07T16:16:24Z&spr=https&sig=uRBiwjUcOo0%2BxUCHVWuwR7xs6YKmk563EampJbotGFo%3D"

#Setup N-Central 
$NCentralFQDN = Get-AzKeyVaultSecret -vaultName "AdaptITKeyVault" -name "NCentralFQDN" -AsPlainText
$SecurePass = Get-AzKeyVaultSecret -vaultName "AdaptITKeyVault" -name "SecurePassWord" -AsPlainText | ConvertTo-SecureString -AsPlainText -Force
$PSUC = Get-AzKeyVaultSecret -vaultName "AdaptITKeyVault" -name "PSUserCredential" -AsPlainText 
$PSUserCredential = New-Object PSCredential ($PSUC, $SecurePass)

if (Get-Module -ListAvailable -Name PS-NCentral) {
    Import-Module PS-NCentral 
}
else {
    Install-Module PS-NCentral -Force
    Import-Module PS-NCentral
}

# Connect to N-Central
$NCConnection = New-NCentralConnection $NCentralFQDN $PSUserCredential

#Fetch Halo Data
$HaloClients = Get-HaloClient 

#Get list of clients (all clients have the DefaultCustomerID as their ParentID)
$AllNCClients = Get-NCCustomerList  
$NCClients = $AllNCClients | Where-Object ParentID -EQ $NCConnection.DefaultCustomerID 

# Connect to Azure Table Storage, check if table exists and if it doesnt, create it
$StorageCTX = New-AzStorageContext -StorageAccountName $StorageAccName -SasToken $SASToken
$TableExists = Get-AzStorageTable -Name $TableName -Context $StorageCTX -ErrorAction SilentlyContinue

if ($null -eq $TableExists) {
    New-AzStorageTable -Name $TableName -Context $StorageCTX

}
$CloudTable = $TableExists.CloudTable

# Create Check line in Azure Table
Add-StorageTableRow -table $CloudTable -partitionkey ([guid]::NewGuid().ToString()) -rowKey ([guid]::NewGuid().ToString()) -property @{
    "Interface"  = "$($CheckDesc)"
    "Date"       = "$($Date)"
    "Check"      = "$($CheckInterface)"
    "ErrorLevel" = "Info"
    "Message"    = "Check Started"
}
# Create a var that allows you to loop through the clients 
$Success = $true

# Loop through each client in both sites, compare and if they dont match, write them to the csv file
ForEach ($EachNCClient in $NCClients) {
    $ThisHaloClient = $HaloClients | Where-Object Name -EQ $EachNCClient.CustomerName

    if (-Not $ThisHaloClient) {
        $Success = $false
        Add-StorageTableRow -table $CloudTable -partitionkey ([guid]::NewGuid().ToString()) -rowKey ([guid]::NewGuid().ToString()) -property @{
            "Interface"  = "$($CheckDesc)"
            "Date"       = "$($Date)"
            "Check"      = "$($CheckInterface)"
            "ErrorLevel" = "Failure"
            "Message"    = "$($EachNCClient.customername)"
        }
    }
}
# If EVERY CUSTOMER matches, write job successful in the csv file
if ($Success -eq $true) {
    Add-StorageTableRow -table $CloudTable -partitionkey ([guid]::NewGuid().ToString()) -rowKey ([guid]::NewGuid().ToString()) -property @{
        "Interface"  = "$($CheckDesc)"
        "Date"       = "$($Date)"
        "Check"      = "$($CheckInterface)"
        "ErrorLevel" = "Success"
        "Message"    = "Job Successful"
    }
}