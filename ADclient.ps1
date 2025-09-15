# run this first to allow execution
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

# Stop execution on error
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$PSNativeCommandUseErrorActionPreference = $true # might be true by default
# Courtesy of https://stackoverflow.com/a/9949105

function Get-Hard-Credential {

    param (
        [Parameter(Mandatory)]
        [string]$domainName
    )

    $user = "$(( $domainName -split '\.' )[0])\Administrator"
    $password = ConvertTo-SecureString -String "Pa`$`$w0rd" -AsPlainText -Force
    $credentialParams = @{
        TypeName = 'System.Management.Automation.PSCredential'
        ArgumentList = $user, $password
    }
    return New-Object @credentialParams
}

$domainName = "sjd0364.lan"
$domainIp = "192.168.1.3"
$interfaceName = "ethernet0"

# Use for hardcoded credentials
$credential = Get-Hard-Credential $domainName
# Use for user entered credientials
#$credential = Get-Credential -Message "Enter admin credientials for the Domain controller"

# Set DNS to the domain controller
Set-DnsClientServerAddress -InterfaceAlias $interfaceName -ServerAddresses ($domainIp)

# Add computer to the domain controller
try {
    Add-computer -domainname $domainName -Credential $credential
}
catch {
    echo "Failed to add computer to domain, please troubleshoot and try again"
    exit 1
}

# restart computer to take affect
echo "Computer has been added to $domainName domain, your pc will restart in 10 seconds for this to take affect. Press ctrl + c to cancel"
Start-Sleep -Seconds 10
Restart-Computer -Force