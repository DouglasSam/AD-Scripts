# run this first to allow execution
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Stop execution on error
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$PSNativeCommandUseErrorActionPreference = $true # might be true by default
# Courtesy of https://stackoverflow.com/a/9949105

# Replace this with Read-Host or modify to allow for different vairables or adjustability
$hostname = "DC01"
$ipAddress = "192.168.1.3"
$prefixLength = 24
$defaultGateway = "192.168.1.1"
$interfaceName = "ethernet0"
$domainName = "sjd0364.lan"

$domainSplit = ($domainName -split '\.') | ForEach-Object { "dc=$_" } 
$domainString = $domainSplit -join ","

# Rename server
if ($env:COMPUTERNAME -ne $hostname) {
    echo "Computer hostname changing, computer will restart in 10 seconds, press ctrl+c to cancel"
    Rename-Computer -NewName $hostname -Force
    Start-Sleep -Seconds 10
    Restart-Computer -Force
}

# Set the static IP address
New-NetIPAddress -InterfaceAlias $interfaceName -IPAddress $ipAddress -PrefixLength $prefixLength -DefaultGateway $defaultGateway
# Set upstream DNS to DefaultGateway
Set-DnsClientServerAddress -InterfaceAlias ethernet0 -ServerAddresses ($defaultGateway)

# Change firewalls to allow incoming pings
Enable-NetFirewallRule -Name FPS-ICMP4-ERQ-In

# Install AD
Install-WindowsFeature AD-Domain-Services
Install-WindowsFeature RSAT-AD-Tools

# Promote  server to domain controller and install DNS
Install-ADDSForest -DomainName $domainName -InstallDns -Force
