#Get the VM's default GW: (Get-NetIPConfiguration -InterfaceAlias "vEthernet (Testing)").IPv4DefaultGateway.NextHop
#Get the VM's current IP: (Get-NetIPConfiguration -InterfaceAlias "vEthernet (Testing)").IPv4Address.IPAddress

$GW = (Get-NetIPConfiguration -InterfaceAlias (Get-NetAdapter).InterfaceAlias).IPv4DefaultGateway.NextHop
#Alt method: ($GW -split("\."))[0]
$FirstOctet =  $GW.Split("\.")[0]
$SecondOctet = $GW.Split("\.")[1]
$ThirdOctet = $GW.Split("\.")[2]

$NetworkPortion = "$FirstOctet.$SecondOctet.$ThirdOctet"
#Test this works in our lab: ping "$NetworkPortion.101"

$Gateway = $GW
$NIC = (Get-NetAdapter).InterfaceAlias
$IP = "$NetworkPortion.130"

#Set IPv4 address, gateway, & DNS servers
New-NetIPAddress -InterfaceAlias $NIC -AddressFamily IPv4 -IPAddress $IP -PrefixLength 24 -DefaultGateway $Gateway
Set-DNSClientServerAddress -InterfaceAlias $NIC -ServerAddresses ("$NetworkPortion.130", "1.1.1.1", "8.8.8.8")

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Rename-Computer -NewName "Marvel-DC" -PassThru -Restart -Force