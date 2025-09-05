$Nodes = Get-ClusterNode -cluster "myCluster" | Select -Expand Name
Enable-VMMigration –Computername $Nodes -ErrorAction Stop| Out-Null
Set-VMHost –Computername $Nodes –VirtualMachineMigrationAuthenticationType Kerberos