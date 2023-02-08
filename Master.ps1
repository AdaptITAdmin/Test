$StorageAccName = "mainadaptstorage"
$StorageAcc = Get-AzStorageAccount -ResourceGroupName "DevAdaptIntegritiesRG" -Name $StorageAccName
$ctx = $StorageAcc.Context

# $Column = "Filename"
$TableName = "IntegrityChecks"
$IntegrityChecks = (Get-AzStorageTable -Table $TableName -Context $ctx)
$row = Get-AzTableRow -Table $IntegrityChecks.CloudTable
$Date = Get-Date
$DateString = $Date.ToString("yyyy-MM-dd-HH:mm")
ForEach ($Check in $row) {
    Write-Host $Check.Filename
    try {
        Invoke-Expression ".\$($Check.Filename) $($DateString) $($Check.Interface) '$($Check.IntegrityCheck)'"
    }
    catch {
        Write-Host "Write failed to launch script line to Azure Table"
    }
}