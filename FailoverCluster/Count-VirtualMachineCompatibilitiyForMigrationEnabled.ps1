$ClusterName = "MyCluster"
$VMProcessors = Get-Cluster $ClusterName | Get-ClusterGroup | Where-Object {(${_}.GroupType -EQ "VirtualMachine")} | ForEach-Object {Get-VMProcessor -VMName ${_}.Name -ComputerName ${_}.OwnerNode}
Write-Output "VM count: $(($VMProcessors | measure).Count)"
Write-Output "Compatibility disabled: $(($VMProcessors | where CompatibilityForMigrationEnabled -EQ $false | measure).Count)"
Write-Output "Compatibility enabled: $(($VMProcessors | where CompatibilityForMigrationEnabled -EQ $true | measure).Count)"