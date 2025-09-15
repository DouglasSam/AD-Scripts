# AD scripts

These are some scripts that I wrote to complete a school project for BCCS 163 where we had two tasks.

## Task 1

This was to set up a workgroup out of three computers. I had to:

Copy clones from P:\Clones and create a workgroup comprising of three computers, two with Windows 10 and one with Windows 11.

They should...

- Be on an internal virtual switch (not vmnet 2, 3, 4 or 5)
- Have static IP addresses and have Internet connectivity via a PfSense firewall (1 mark)
- Contain five user accounts: Leon, Lucy, Luke, Lily and Leo (These accounts all start with "L" to remind us that they are local user accounts.) (1 mark)
- One of the machines should contain a share with data that is shared to the other two machines. (2 mark)

This is handled by the [Task1.ps1](Task1.ps1) script which sets all that up doing:

-	Statically define the IP network address and default gateway
-	Presumes the DNS server is the default gateway
-	Get the user to input the last octet for the machine IP
-	Get the user to input a new computer hostname
-	Statically creates all the required users in the standard user group
-	Asks the user if they want to create a network share
  -	Creates the share with administrators having full access and the required users having change access to the share
-	Changes the hostname and restarts the computer

## Task 2

This was to expand the task 1 by having an active directory controller to manage logins and file hosting. I had to:

Copy a Windows Server (but not the Core version) from P:\Clones and create a domain environment with a single Windows Server 2022 domain controller. Then use the three computers of Task 1 (so two Windows 10 and one Windows 11 machine).

Make sure that...

- The three computers of Task 1 are all on the same internal virtual switch (not vmnet 2, 3, 4 or 5)
- Make use of a static IP address on the domain controller and promote it to a domain controller using a domain name of your choosing (1 mark)
- Create five domain user accounts on the domain controller, namely David, Debbie, Dominic, Diana and Dean (These all start with the letter "D" to remind us that they are domain accounts.) (1 mark)
- You can log in as David, Debbie, Dominic, Diana and Dean from any of the Windows clients (1 mark)
- The domain controller has a share that all machines can access (1 mark)
- Finally (that is, the last thing you do) add a PfSense firewall and check that all six machines can now access the firewall (1 mark)

Setting up the domain controller is done in two parts, first you run [ADserver-pt1.ps1](ADserver-pt1.ps1), which you need to run twice.

This script first sets the hostname of the server, in this case to DC01 then restarts to apply the hostname.

Running it, the second time will set the ip address, default gateway, DNS server, allow incoming pings, install Active Directory and make this host a domain controller also installing the DNS server through that.

The final Install-ADDSForest command auto restarts the computer to apply the changes requiring the script to be in two parts.

The second script [ADserver-pt2.ps1](ADserver-pt2.ps1) will:

-	Enable the AD recycle bin
-	Adds an organizational unit and AD group for the required users
-	Add the required users
-	Creates a network share with the AD group of the users as change access

To set up clients on the domain run the [ADclient.ps1](ADclient.ps1) which:

-	Changes the DNS server to be the domain controller IP address
-	Adds the computer to the domain controller
-	Reboots to make the change take effect.

## Notes

Being a school project where I wanted as little to do as possible a lot of this script is hardcoded.
This does include things like the passwords so DO NOT use something like this in production. 

## Networking

If anybody is interested the networking was handled by a pfSense VM.

For the network I decided to go with a standard 192.168.1.0/24 network and the firewall has the LAN address of 192.168.1.1. 

The Task 1 script sets the workgroup hosts to be in that network and the user just has to provide the last octet of the ip address. The IP address of the domain controller is hardcoded to 192.168.1.3.

I have set up pfSense as a DNS server using DNS Resolver.
I have also turned off the DHCP server as it is not needed for this exercise but have preconfigured it to use the IP range of 192.168.1.100 – 192.168.1.200 for DHCP clients and give out the DNS server of 192.168.1.3 (domain controller + DNS server) if one is required.



