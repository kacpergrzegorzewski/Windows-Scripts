$Nodes = "node01","node02"

$DomainName = "mydomain.local"

Foreach ($Node in $Nodes){
        Write-Host "-------- $Node ------"
        Foreach ($VMHost in $Nodes){
            If ($Node -notlike $VMHost){
                Write-Host " -> $VMHost"
                Get-ADComputer $Node | Set-ADObject -Add @{"msDS-AllowedToDelegateTo"="Microsoft Virtual System Migration Service/$($VMHost).$($DomainName)", "cifs/$($VMHost).$DomainName","Microsoft Virtual System Migration Service/$($VMHost)","cifs/$($VMHost)"}
        }
    }
}