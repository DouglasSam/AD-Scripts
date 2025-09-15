
# run this first to allow execution
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Stop execution on error
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$PSNativeCommandUseErrorActionPreference = $true # might be true by default
# Courtesy of https://stackoverflow.com/a/9949105

# Replace this with Read-Host or modify to allow for different vairables or adjustability
$domainName = "sjd0364.lan"
$shareName = "DomainShare"
$defaultPassword = ConvertTo-SecureString -String "Pa`$`$w0rd" -AsPlainText -Force

$userOU = "DomainUsers"

$domainSplit = ($domainName -split '\.') | ForEach-Object { "DC=$_" } 
$domainString = $domainSplit -join ","

# Enable the AD recycle bin
Import-Module ActiveDirectory
$recycleBinDN = "CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,$domainString"
Enable-ADOptionalFeature -Identity $recycleBinDN -Scope ForestOrConfigurationSet -Target $domainName

# Add in ou for ease of finding
New-ADOrganizationalUnit -Name $userOU -Path $domainString

# Add in group for smb permissions
New-ADGroup -Name $userOU -GroupCategory Security -GroupScope Global -Path "OU=$userOU,$domainString"

# Add the AD Users (ADUC for gui) (example script at P:\Courses\BCCS163\add-user.ps1)
$users = @("David", "Debbie", "Dominic", "Diana", "Dean")
foreach ( $user in $users ) {
    # Create AD user
    New-ADUser  -Name $user `
                -SamAccountName $user `
                -UserPrincipalName "$user@$domainName" `
                -AccountPassword $defaultPassword `
                -Enabled $True `
                -PasswordNeverExpires $True `
                -ChangePasswordAtLogon $False `
                -Path "OU=$userOU,$domainString"
    # Add AD user to a group
    Add-ADGroupMember -Identity $userOU -Members $user
}

# add smb share
$sharePath = 'C:\share'
mkdir $sharePath -Force

# Get the AD Domain name from Powershell
$ADDomainName = (get-addomain).Name

Write-Output "Welcome to the local SMB share running on $domainName domain controller with the domain name of $ADDomainName" > $sharePath/README.txt
Write-Output "This README was generated at: " >> $sharePath/README.txt
Get-Date >> $sharePath/README.txt

$Parameters = @{
    Name       = $shareName
    Path       = $sharePath
    ChangeAccess = $userOU # change access to domain users
    FullAccess = 'Administrators' # Full access to local administrators
}

New-SmbShare @Parameters