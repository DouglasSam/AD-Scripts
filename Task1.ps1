# run this first to allow execution
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

function Get-logicalYesNo([string]$question) {
do { $sAnswer = Read-Host "$question [Y/N]" } until ($sAnswer.ToUpper()[0] -match '[yYnN]')
    return ($sAnswer.ToUpper()[0] -match '[Y]') #return  $True or $False
}
# Courtesy of https://stackoverflow.com/a/78036916

# Stop execution on error
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$PSNativeCommandUseErrorActionPreference = $true # might be true by default
# Courtesy of https://stackoverflow.com/a/9949105

$hostname = Read-Host "Enter new Hostname: "

# Set the static ip addresses
$IP = Read-Host "Enter the host ip octet: "
$networkHost = "192.168.1."
$defaultGateway = $networkHost+"1"
$prefixLength = 24
$interfaceName = "ethernet0"

New-NetIPAddress -InterfaceAlias $interfaceName -IPAddress $networkHost$IP -PrefixLength $prefixLength -DefaultGateway $defaultGateway
Set-DnsClientServerAddress -InterfaceAlias ethernet0 -ServerAddresses ($defaultGateway)

# Create the users
$password = (ConvertTo-SecureString "Pa`$`$w0rd" -AsPlainText -Force)
$users = @('Leon','Lucy','Luke','Lily', 'Leo')
foreach ( $user in $users )
{
    # Create the user
	New-LocalUser -Name $user -AccountNeverExpires -Description "Local account for $user" -Password $password
    # Add user to Users group for login
    Add-LocalGroupMember -Group "Users" -Member $user
}

if (Get-logicalYesNo "Create smb (network) share?") {
    $sharePath = 'C:\share'
    $shareName = 'LocalShare'
    mkdir $sharePath -Force

    # Give the 5 local users access
    $computerName = $env:COMPUTERNAME
    $fullAccessAccounts = $users | ForEach-Object { "$computerName\$_" }

    Write-Output "Welcome to the local SMB share running on $computerName" > $sharePath/README.txt
    Write-Output "This README was generated at: " >> $sharePath/README.txt
    Get-Date >> $sharePath/README.txt

    $Parameters = @{
        Name       = $shareName
        Path       = $sharePath
	    ChangeAccess = $fullAccessAccounts
        FullAccess = 'Administrators'
    }

    New-SmbShare @Parameters
}

# Rename computer to something nicer
if ($env:COMPUTERNAME -ne $hostname) {
    echo "Computer hostname changing, computer will restart in 10 seconds, press ctrl+c to cancel"
    Rename-Computer -NewName $hostname -Force
    Start-Sleep -Seconds 10
    Restart-Computer -Force
}