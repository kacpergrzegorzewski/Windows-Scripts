$NetworkAdapter = "Ethernet0"
$IPAddress = 10.2.42.41
$PrefixLength = 24
$DefaultGateway = 10.2.42.1
$DNSServerAddresses = 8.8.8.8,8.8.4.4
$ComputerName = "wgcl01"
$WorkgroupName = "wgcl"
$DomainSuffix = "wgcl.local"
$NodeList = "wgcl01","wgcl02","wgcl03"
$NodeIPList = "10.2.42.41","10.2.42.42","10.2.42.43"
$ClusterName = "wgcl"
$ClusterIP = 10.4.42.44

# 
# Basic configuration
#
Rename-Computer $ComputerName
Rename-Adapter -name $NetworkAdapter -NewName Ethernet
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -serverAddresses $DNSServerAddresses
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $DefaultGateway
Set-DnsClientGlobalSetting -SuffixSearchList @($DomainSuffix)

netsh advfirewall firewall add rule name="Allow ICMP" protocol="icmpv4:8,any" dir=in action=allow

# Add nodes IPs to etc/hosts file 
for ($i = 0; $i -lt $NodeList.Count; $i++) {
    $NodeName = $NodeList[$i]
    $NodeIPAddress = $NodeIPList[$i]
    Add-Content -Path $env:windir\System32\drivers\etc\hosts -Value "`n${NodeIPAddress}`t${NodeName}" -Force
    Add-Content -Path $env:windir\System32\drivers\etc\hosts -Value "`n${NodeIPAddress}`t${NodeName}.${DomainSuffix}" -Force
}

# Add cluster ip name to etc/hosts file
Add-Content -Path $env:windir\System32\drivers\etc\hosts -Value "`n${ClusterIP}`t${ClusterName}" -Force
Add-Content -Path $env:windir\System32\drivers\etc\hosts -Value "`n${ClusterIP}`t${ClusterName}.${DomainSuffix}" -Force

Add-Computer -WorkgroupName $WorkgroupName
netdom computername $ComputerName /add:$ComputerName.$DomainSuffix
netdom computername $ComputerName /makeprimary:$ComputerName.$DomainSuffix

# Add trusted hosts
$TrustedHosts = ""
for ($i = 0; $i -lt $NodeList.Count; $i++) {
    $NodeName = $NodeList[$i]
    $FullNodeName = "${NodeName}.${DomainSuffix}"
    $TrustedHosts = $TrustedHosts + $NodeName + "," + $FullNodeName + ","
}
# Remove last comma
$TrustedHosts = $TrustedHosts.Substring(0,$TrustedHosts.Length-1)

Set-Item WSMan:\localhost\Client\TrustedHosts -Value "cv01,cv01.commcell.local,cv02,cv02.commcell.local,cv,file,file.commcell.local"


# Restart computer to apply changes
Restart-Computer


#
# Create cluster on one node
#
Install-WindowsFeature -Name Failover-Clustering, FS-FileServer, FS-Resource-Manager, RSAT-Clustering-PowerShell -IncludeAllSubFeature -IncludeManagementTools -verbose

Test-Cluster -Nodes $NodeList
New-Cluster -Name $ClusterName -Node $NodeName -StaticAddress $ClusterIP -NoStorage -AdministrativeAccessPoint DNS

#
# Add all other nodes (local console on each node)
#

Add-ClusterNode -Cluster $ClusterName -Name $NodeName
