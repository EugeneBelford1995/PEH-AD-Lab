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
$IP = "$NetworkPortion.131"
$ComputerName = "ThePunisher"

#Set IPv4 address, gateway, & DNS servers
New-NetIPAddress -InterfaceAlias $NIC -AddressFamily IPv4 -IPAddress $IP -PrefixLength 24 -DefaultGateway $Gateway
Set-DNSClientServerAddress -InterfaceAlias $NIC -ServerAddresses ("$NetworkPortion.130", "1.1.1.1", "8.8.8.8")
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes

#Disable IPv6 (We will re-enable this later if needed for the MITM6 lab)
Disable-NetAdapterBinding -InterfaceAlias $NIC -ComponentID ms_tcpip6

#Disable SMB Signing
Set-SmbClientConfiguration -RequireSecuritySignature $false -Force
Set-SmbServerConfiguration -RequireSecuritySignature $false -Force

# --- Setup local accounts per PEH ---

#Store a password (borrowed from our DSRM routine)
[string]$DSRMPassword = 'Password1!'
# Convert to SecureString
[securestring]$SecureStringPassword = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force

Set-LocalUser "Administrator" -Password $SecureStringPassword

#Store a password (borrowed from our DSRM routine)
[string]$DSRMPassword = 'Password1'
# Convert to SecureString
[securestring]$SecureStringPassword2 = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force

New-LocalUser "FrankCastle" -FullName "Frank Castle" -Description "The Punisher, local account" -Password $SecureStringPassword2
Start-Sleep -Seconds 30
Add-LocalGroupMember -Group "Administrators" -Member "FrankCastle"

# --- Final steps; install RSAT, rename the computer, and reboot ---
Install-WindowsFeature -Name "RSAT" -IncludeAllSubFeature
Rename-Computer -NewName $ComputerName -PassThru -Restart -Force