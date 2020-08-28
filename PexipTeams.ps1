# Powershell variables
# Set the following variables for ease of use of the next commands - if starting a new window, just re-set these variables.

# Name prefix for all Teams Connector resources, e.g. company name.
# PxBaseConnName can have a maximum of 9 characters
# PxBaseConnName + PxVmssRegion must be minimum 3 and maximum 14 chars when combined 
# It cannot contain dashes, spaces or other non a-z0-9 chars.
$PxBaseConnName = "RenRe" # replace with your company name
 
# Freetext region shortname (no dashes, only use a-z) to separate regional deployments
$PxVmssRegion = "eu"

# Hostname of Teams Connector in Azure - Must match name in pfx certificate below
# You need a different hostname for each region
$PxTeamsConnFqdn = ""
 
# Conference or Edge node pool (must be reachable from Teams Connector in Azure)
# This name must exist in the certificate presented by the Pexip nodes
# Example 1) Multiple individual Edge nodes
# $PxNodeFqdns = "us-pxedge01.vc.example.com,us-pxedge01.vc.example.com"
# Example 2) Certificate with SAN names, this name is in the cert presented by all nodes
$PxNodeFqdns = ""

# Azure Subscription ID for Pexip Teams Connector deployment
$PxSubscriptionId = ""
 
# Azure Region (must be a supported region)
$PxAzureLocation = "northeurope"
 
# Username for the Windows VM accounts
$PxWinAdminUser = ""
 
# Password for the Windows VM accounts (can be set with Get-Credential if desired)
$PxWinAdminPassword = "" # Password for Windows account
 
# Number of Teams Connector VMs
$PxTeamsConnInstanceCount = "3"

# Setting the regional resource group name
$PxTeamsConnResourceGroupName = "$($PxBaseConnName)-TeamsConn-$($PxVmssRegion)-RG"

# Setting the STATIC regional resource group name
$PxTeamsConnStaticResourceGroupName = "$($PxBaseConnName)-TeamsConn-$($PxVmssRegion)-static-RG"
 
# Enable incident reporting 
$PxTeamsConnIncidentReporting = $true

# Enable VMSS disk encryption
# This requires Disk Encryption to be registered on the subscription first
# https://blogs.msdn.microsoft.com/azuresecurity/2017/09/28/announcing-azure-disk-encryption-preview-for-virtual-machine-scale-sets/
# Verify if this is enabled by running:
# Get-AzureRmProviderFeature -ProviderNamespace "Microsoft.Compute" -FeatureName "UnifiedDiskEncryption"
$PxTeamsConnDiskEncryption = $false
 
# Wildcard, SAN or single name cert for FQDN of Teams Connector (PxTeamsConnServiceFQDN), 
# the PFX must contain the intermediate chain as well.
$PxPfxCertFileName = ".\pexip-teams.pfx"
 
# Management networks – used for RDP access and admin consent
# If not specified (default) – RDP is always blocked
# Any security scans should not come from these IPs
# Example:
# x.x.x.x     Management IP address #1
# y.y.y.y     Management IP address #2
# z.z.z.0/24  Management subnet
# $PxMgmtSrcAddrPrefixes = @( "x.x.x.x", "y.y.y.y", "z.z.z.0/24" ) 
$PxMgmtSrcAddrPrefixes = @() 

# Pexip public facing Conferencing / Edge node IP addresses
# If not specified (default) – HTTPS access is always enabled
# If specifying IPs, then in addition to the Pexip node IP addresses you MUST also include
# the external IP address of the workstation / management network that will be used to 
# provide consent for the Teams Connector apps (otherwise 443 will be blocked)
#
# Example Pexip Edge nodes public IP source ports:
# a.a.a.a    - IP of us-pxedge01.vc.example.com
# c.c.c.0/28 – IP subnet of eu-pxedges (allows for future expansion)
#
# Example (specifying Pexip edge nodes and Management networks defined above):
# $PxNodesSourceAddressPrefixes = @( "a.a.a.a", "c.c.c.0/28" ) + $PxMgmtSrcAddrPrefixes
$PxNodesSourceAddressPrefixes = @("","")



# Connect to PowerShell AzureAD, AzureRm and import Pexip CVI module
# Azure AD commands
# Connect to AzureAD
# If AAD/365 admin is not the same as Azure Resource Manager admin,
# the next section is to be run by the AAD admin.
#
# IMPORTANT: The output of IDs/credentials here must be saved as it will be required later
#
Connect-AzureAD

# Set execution policy for the current PowerShell process
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process

# Connect to Azure Resource Manager PowerShell (in same window to reuse variables)
# This step can be omitted if you only are running the AAD commands to create trusted Apps
Import-Module AzureRM -MinimumVersion 6.0.0
Connect-AzureRmAccount

# Import the PexTeamsCviApplication PowerShell module
Import-Module .\NewPexTeamsCviApplication.psm1

# Create two new CVI Applications, one Trusted, and one Guest
# Create Trusted App
$TrustedApp = New-PexTeamsCviApplication -AppDisplayName "$($PxBaseConnName)TeamsConnTrusted" -ConnectorFqdn $PxTeamsConnFqdn -Confirm:$false
$TrustedAppId = $TrustedApp.AppId

# Create Trusted App Password
$TrustedAppPassword = ($TrustedApp | New-PexTeamsCviApplicationPasswordCredential -KeyIdentifier default).Value

# Create Guest App
$GuestApp = New-PexTeamsCviApplication -AppDisplayName "$($PxBaseConnName)TeamsConnGuest" -ConnectorFqdn $PxTeamsConnFqdn -Confirm:$false
$GuestAppId = $GuestApp.AppId

# Create Guest App Password
$GuestAppPassword = ($GuestApp | New-PexTeamsCviApplicationPasswordCredential -KeyIdentifier default).Value

Write-Host
Write-Host
Write-Host "`n----------------------------------------`n"
Write-Host
Write-Host "### App ID and credentials MUST be saved in the redeploy script ###"
Write-Host
Write-Host "`$TrustedAppId = `"$($TrustedAppId)`""
Write-Host "`$TrustedAppPassword = `"$($TrustedAppPassword)`""
Write-Host "`$GuestAppId = `"$($GuestAppId)`""
Write-Host "`$GuestAppPassword = `"$($GuestAppPassword)`""
Write-Host
Write-Host "`n----------------------------------------`n"
Write-Host
Write-Host

# Azure RM commands
# Change context to the Pexip Subscription and set the Trust/Guest credentials
Set-AzureRmContext -SubscriptionId $PxSubscriptionId
 
$TrustedAppSecurePassword = ConvertTo-SecureString -AsPlainText $TrustedAppPassword -Force
$TrustedAppCred = New-Object System.Management.Automation.PSCredential -ArgumentList $TrustedAppId,$TrustedAppSecurePassword
 
$GuestAppSecurePassword = ConvertTo-SecureString -AsPlainText $GuestAppPassword -Force
$GuestAppCred = New-Object System.Management.Automation.PSCredential -ArgumentList $GuestAppId,$GuestAppSecurePassword
  
# Bot channel registration
# The Bot Channel registration is used globally, and only needs to be created once (in any of your regions)

# Bot channel Resource group creation (in your main region)
New-AzureRmResourceGroup -Location $PxAzureLocation -ResourceGroupName "$($PxBaseConnName)-TeamsBotChan-RG"

# Bot channel registrations for the trusted and the guest AppID
# Create trusted bot
Register-PexTeamsCviApplicationBot -SubscriptionId $PxSubscriptionId -ResourceGroupName "$($PxBaseConnName)-TeamsBotChan-RG" -BotName "$($PxBaseConnName)-Trusted-TeamsBot" -AppId $TrustedAppId -Confirm:$false
 
# Create guest bot
Register-PexTeamsCviApplicationBot -SubscriptionId $PxSubscriptionId -ResourceGroupName "$($PxBaseConnName)-TeamsBotChan-RG" -BotName "$($PxBaseConnName)-Guest-TeamsBot" -AppId $GuestAppId -Confirm:$false

# Virtual Machine Scale Set (VMSS) creation
# Provide credentials to be used as local user/password for Pexip Teams Connector VMs
# Create a password (using the variables above) for the Windows VM
$PxWinAdminSecurePassword = ConvertTo-SecureString -AsPlainText $PxWinAdminPassword -Force
$PxWinAdminCred = New-Object System.Management.Automation.PSCredential -ArgumentList $PxWinAdminUser,$PxWinAdminSecurePassword
 
# Optionally if you do not prefer to have a password set as a variable, use Get-Credential
# $PxWinAdminCred = Get-Credential
 
# Create Resource group for Teams Connector Load Balancer (per region)
# This stores the public IP address of the Teams Connector Load Balancer
# so that the address can be re-used on upgrade or redeploy
New-AzureRmResourceGroup -Location $PxAzureLocation -ResourceGroupName $PxTeamsConnStaticResourceGroupName -Force

# Create Resource group for Teams Connector VMSS (per region)
New-AzureRmResourceGroup -Location $PxAzureLocation -ResourceGroupName $PxTeamsConnResourceGroupName

# Ensure required version of the Carbon Powershell module is used
(Get-Content NewTeamsConnectorDSCConfig.ps1).replace('Install-Module -Name Carbon -AllowClobber', 'Install-Module -Name Carbon -RequiredVersion 2.6.0 -AllowClobber') | Set-Content NewTeamsConnectorDSCConfig.ps1

# Deploy the Teams Connector VMs
# this step can take up to 30 minutes to complete
.\newcreate_vmss_deployment.ps1 -SubscriptionId $PxSubscriptionId -ResourceGroupName $PxTeamsConnResourceGroupName -VmssName "$($PxBaseConnName)$($PxVmssRegion)" -VMAdminCredential $PxWinAdminCred -PfxPath $PxPfxCertFileName -TeamsConnectorFqdn $PxTeamsConnFqdn -PexipFqdns $PxNodeFqdns -instanceCount $PxTeamsConnInstanceCount -TrustedAppCredential $TrustedAppCred -GuestAppCredential $GuestAppCred -StaticResourcesResourceGroupName $PxTeamsConnStaticResourceGroupName -PublicIPAddressResourceName "$($PxBaseConnName)-TeamsConn-$($PxVmssRegion)-PIP" -IncidentReporting $PxTeamsConnIncidentReporting -Encryption $PxTeamsConnDiskEncryption -RdpSourceAddressPrefixes $PxMgmtSrcAddrPrefixes -PexipSourceAddressPrefixes $PxNodesSourceAddressPrefixes

# supply the PFX certificate file password when prompted

# Please enter the password for the PFX certificate '.\xxxxxxxx.pfx': ***************
 
 
# Generating the next steps summary (this assumes you are connected to AzureAD and AzureRM)
#
# Setting subscription
Set-AzureRmContext -SubscriptionId $PxSubscriptionId

# Getting Network Security Group Resource ID
$nsgResId = (Get-AzureRmResource -ResourceGroupName $PxTeamsConnResourceGroupName -ResourceType Microsoft.Network/networkSecurityGroups).ResourceId

# Getting Public IP details
$publicIpAddress = (Get-AzureRmPublicIpAddress -ResourceGroupName $PxTeamsConnStaticResourceGroupName).IpAddress
$publicIpFqdn = (Get-AzureRmPublicIpAddress -ResourceGroupName $PxTeamsConnStaticResourceGroupName).DnsSettings.Fqdn

# Getting Tenant Details
$tenant = Get-AzureADTenantDetail
$tenantDomain = ($tenant.VerifiedDomains | Where-Object { $_._Default -eq $True }).Name

# Printing next steps
Write-Host 
Write-Host 
Write-Host "`n--------------------------`n"
Write-Host 
Write-Host "When the Teams Connector is deployed, you have to create a DNS CNAME from your official hostname"
Write-Host "then the Office 365 admin must consent for the AppIds to join Teams Meetings"
Write-Host
Write-Host "1) Setup a DNS CNAME for $($PxTeamsConnFqdn) pointing to "
Write-Host "   $($publicIpFqdn)"
Write-Host
Write-Host "   When this is done, and you can confirm a DNS lookup of $($PxTeamsConnFqdn) resolves to"
Write-Host "   your Public IP of the load balancer ($($publicIpAddress)) - you are ready to proceed."
Write-host
Write-Host "2) Give consent to trusted and guest apps. Go to: https://$($PxTeamsConnFqdn)/adminconsent"
Write-Host
Write-Host "   If Management Source Address prefixes and Pexip Conferencing Node IPs are defined,"
Write-Host "   the administrator doing consent must come from one of these addresses."
Write-Host "   Pexip node prefixes: $($PxNodesSourceAddressPrefixes)"
Write-Host "   If your Office 365 admin comes from a different IP, add it to the Azure Network Security Group (NSG)"
Write-Host
Write-Host "   NSG inbound rules can be found here:"
Write-Host "   https://portal.azure.com/#@${tenantDomain}/resource${nsgResId}/inboundSecurityRules"
Write-Host
Write-Host "   Add an additional inbound rule allowing 443/TCP from your Office 365 administrator's source IP to Any"
Write-Host 
Write-Host "   This is not required if you had no Management Prefixes - you can access it directly."
Write-Host 
Write-Host "`n--------------------------`n"
Write-Host 
Write-Host

