$ClusterName = "MyCluster"
Get-Cluster -Name $ClusterName | Get-ClusterNode | ForEach-Object {Get-VMHost -ComputerName ${_}.Name} | select ComputerName,VirtualMachineMigrationAuthenticationType,VirtualMachineMigrationPerformanceOption
