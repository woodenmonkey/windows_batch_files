<#
.SYNOPSIS
    Read-only inventory of an Azure tenant: resource groups, networking,
    storage, compute, and database resources.

.DESCRIPTION
    Enumerates every subscription the signed-in account can see and writes one
    CSV per resource category, plus a summary. Every call is a GET -- this
    script creates, modifies, and deletes nothing.

    Written for discovery against an unfamiliar tenant, so it degrades rather
    than fails: a subscription or resource type the account cannot read is
    recorded in the errors file and the run continues. An empty CSV therefore
    means "none found OR not readable" -- check Errors.csv before concluding a
    resource type is absent.

.PARAMETER TenantId
    Tenant to connect to. If already connected, pass -SkipLogin instead.

.PARAMETER SubscriptionId
    Limit to specific subscriptions. Omit to cover every visible subscription.

.PARAMETER OutputPath
    Directory for the CSVs. Created if missing. Defaults to a timestamped
    folder under the current directory.

.PARAMETER SkipLogin
    Use the existing Az context rather than calling Connect-AzAccount.

.PARAMETER IncludeNsgRules
    Also enumerate individual NSG security rules. Off by default because it is
    one extra call per NSG and the output is long; on for a real firewall review.

.EXAMPLE
    .\Invoke-AzureDiscovery.ps1 -TenantId '00000000-0000-0000-0000-000000000000'

.EXAMPLE
    .\Invoke-AzureDiscovery.ps1 -SkipLogin -IncludeNsgRules -OutputPath C:\discovery

.NOTES
    Requires the Az PowerShell module:
        Install-Module Az -Scope CurrentUser -Repository PSGallery

    Needs Reader at subscription scope (or higher) to be useful. Reader is
    sufficient for everything here -- no write permission is required or used.
#>

[CmdletBinding()]
param(
    [string]$TenantId,
    [string[]]$SubscriptionId,
    [string]$OutputPath = (Join-Path (Get-Location) ("AzDiscovery_" + (Get-Date -Format 'yyyyMMdd_HHmmss'))),
    [switch]$SkipLogin,
    [switch]$IncludeNsgRules
)

$ErrorActionPreference = 'Stop'

# Collectors. One list per output CSV; each is written once at the end so a
# failure partway through still leaves whatever was gathered.
$results = @{
    Subscriptions   = [System.Collections.Generic.List[object]]::new()
    ResourceGroups  = [System.Collections.Generic.List[object]]::new()
    VirtualNetworks = [System.Collections.Generic.List[object]]::new()
    Subnets         = [System.Collections.Generic.List[object]]::new()
    Peerings        = [System.Collections.Generic.List[object]]::new()
    NSGs            = [System.Collections.Generic.List[object]]::new()
    NSGRules        = [System.Collections.Generic.List[object]]::new()
    PublicIPs       = [System.Collections.Generic.List[object]]::new()
    PrivateEndpoints= [System.Collections.Generic.List[object]]::new()
    StorageAccounts = [System.Collections.Generic.List[object]]::new()
    VirtualMachines = [System.Collections.Generic.List[object]]::new()
    Disks           = [System.Collections.Generic.List[object]]::new()
    SqlServers      = [System.Collections.Generic.List[object]]::new()
    SqlDatabases    = [System.Collections.Generic.List[object]]::new()
    OtherDatabases  = [System.Collections.Generic.List[object]]::new()
    Errors          = [System.Collections.Generic.List[object]]::new()
}

function Write-Step {
    param([string]$Message, [string]$Colour = 'Cyan')
    Write-Host $Message -ForegroundColor $Colour
}

function Add-DiscoveryError {
    <# Record a failure without aborting. Discovery against an unfamiliar
       tenant hits permission gaps constantly; each one is data, not a stop. #>
    param([string]$Subscription, [string]$Area, [string]$Message)
    $results.Errors.Add([pscustomobject]@{
        Subscription = $Subscription
        Area         = $Area
        Message      = $Message
    })
    Write-Warning "[$Subscription/$Area] $Message"
}

function Invoke-Safely {
    <# Run a collection scriptblock, routing any failure to the error list.
       Returns an empty array on failure so callers can pipe unconditionally. #>
    param(
        [scriptblock]$Script,
        [string]$Subscription,
        [string]$Area
    )
    try {
        $out = & $Script
        if ($null -eq $out) { return @() }
        return @($out)
    } catch {
        Add-DiscoveryError -Subscription $Subscription -Area $Area -Message $_.Exception.Message
        return @()
    }
}

# --- module + connection ----------------------------------------------------

if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
    throw "Az PowerShell module not found. Install with: Install-Module Az -Scope CurrentUser -Repository PSGallery"
}

if (-not $SkipLogin) {
    Write-Step "Connecting to Azure..."
    if ($TenantId) {
        Connect-AzAccount -Tenant $TenantId -ErrorAction Stop | Out-Null
    } else {
        Connect-AzAccount -ErrorAction Stop | Out-Null
    }
}

$context = Get-AzContext
if (-not $context) {
    throw "No Az context. Run Connect-AzAccount, or drop -SkipLogin."
}
Write-Step ("Signed in as {0} on tenant {1}" -f $context.Account.Id, $context.Tenant.Id) 'Green'

# --- subscriptions ----------------------------------------------------------

$subs = if ($SubscriptionId) {
    $SubscriptionId | ForEach-Object { Get-AzSubscription -SubscriptionId $_ }
} elseif ($TenantId) {
    Get-AzSubscription -TenantId $TenantId
} else {
    Get-AzSubscription
}

if (-not $subs) {
    throw "No subscriptions visible to this account. It may have directory access but no subscription-level RBAC."
}
Write-Step ("Found {0} subscription(s)." -f @($subs).Count) 'Green'

# --- per-subscription sweep -------------------------------------------------

foreach ($sub in $subs) {
    $subName = $sub.Name
    Write-Step "`n=== $subName ($($sub.Id)) ==="

    try {
        Set-AzContext -SubscriptionId $sub.Id -ErrorAction Stop | Out-Null
    } catch {
        Add-DiscoveryError -Subscription $subName -Area 'Context' -Message $_.Exception.Message
        continue
    }

    $results.Subscriptions.Add([pscustomobject]@{
        Name     = $subName
        Id       = $sub.Id
        TenantId = $sub.TenantId
        State    = $sub.State
    })

    # Resource groups ---------------------------------------------------------
    Write-Host "  resource groups..." -NoNewline
    $rgs = Invoke-Safely -Subscription $subName -Area 'ResourceGroups' -Script { Get-AzResourceGroup }
    foreach ($rg in $rgs) {
        $results.ResourceGroups.Add([pscustomobject]@{
            Subscription = $subName
            Name         = $rg.ResourceGroupName
            Location     = $rg.Location
            # Tags flattened to a single cell so the CSV stays one row per RG.
            Tags         = if ($rg.Tags) { ($rg.Tags.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '; ' } else { '' }
            ProvisioningState = $rg.ProvisioningState
        })
    }
    Write-Host " $(@($rgs).Count)"

    # Virtual networks, subnets, peerings -------------------------------------
    Write-Host "  virtual networks..." -NoNewline
    $vnets = Invoke-Safely -Subscription $subName -Area 'VirtualNetworks' -Script { Get-AzVirtualNetwork }
    foreach ($vnet in $vnets) {
        $results.VirtualNetworks.Add([pscustomobject]@{
            Subscription  = $subName
            ResourceGroup = $vnet.ResourceGroupName
            Name          = $vnet.Name
            Location      = $vnet.Location
            AddressSpace  = ($vnet.AddressSpace.AddressPrefixes -join ', ')
            DnsServers    = ($vnet.DhcpOptions.DnsServers -join ', ')
            SubnetCount   = @($vnet.Subnets).Count
        })

        foreach ($subnet in $vnet.Subnets) {
            $results.Subnets.Add([pscustomobject]@{
                Subscription     = $subName
                ResourceGroup    = $vnet.ResourceGroupName
                VNet             = $vnet.Name
                Subnet           = $subnet.Name
                AddressPrefix    = ($subnet.AddressPrefix -join ', ')
                NSG              = if ($subnet.NetworkSecurityGroup) { ($subnet.NetworkSecurityGroup.Id -split '/')[-1] } else { '' }
                RouteTable       = if ($subnet.RouteTable) { ($subnet.RouteTable.Id -split '/')[-1] } else { '' }
                # Delegations matter for discovery: they reveal PaaS services
                # injected into the VNet that own no visible resource of their own.
                Delegations      = ($subnet.Delegations | ForEach-Object { $_.ServiceName }) -join ', '
                ServiceEndpoints = ($subnet.ServiceEndpoints | ForEach-Object { $_.Service }) -join ', '
                ConnectedDevices = @($subnet.IpConfigurations).Count
            })
        }

        # Peerings show where the network actually reaches -- often the most
        # useful single artifact when mapping an unfamiliar estate.
        foreach ($peer in $vnet.VirtualNetworkPeerings) {
            $results.Peerings.Add([pscustomobject]@{
                Subscription      = $subName
                ResourceGroup     = $vnet.ResourceGroupName
                LocalVNet         = $vnet.Name
                PeeringName       = $peer.Name
                RemoteVNet        = if ($peer.RemoteVirtualNetwork) { ($peer.RemoteVirtualNetwork.Id -split '/')[-1] } else { '' }
                RemoteVNetId      = if ($peer.RemoteVirtualNetwork) { $peer.RemoteVirtualNetwork.Id } else { '' }
                PeeringState      = $peer.PeeringState
                AllowForwarded    = $peer.AllowForwardedTraffic
                AllowGatewayTransit = $peer.AllowGatewayTransit
                UseRemoteGateways = $peer.UseRemoteGateways
            })
        }
    }
    Write-Host " $(@($vnets).Count)"

    # Network security groups -------------------------------------------------
    Write-Host "  network security groups..." -NoNewline
    $nsgs = Invoke-Safely -Subscription $subName -Area 'NSGs' -Script { Get-AzNetworkSecurityGroup }
    foreach ($nsg in $nsgs) {
        $results.NSGs.Add([pscustomobject]@{
            Subscription    = $subName
            ResourceGroup   = $nsg.ResourceGroupName
            Name            = $nsg.Name
            Location        = $nsg.Location
            CustomRuleCount = @($nsg.SecurityRules).Count
            AttachedSubnets = ($nsg.Subnets | ForEach-Object { ($_.Id -split '/')[-1] }) -join ', '
            AttachedNICs    = ($nsg.NetworkInterfaces | ForEach-Object { ($_.Id -split '/')[-1] }) -join ', '
        })

        if ($IncludeNsgRules) {
            # Custom rules only. The default rules are identical everywhere and
            # would bury the ones somebody actually wrote.
            foreach ($rule in $nsg.SecurityRules) {
                $results.NSGRules.Add([pscustomobject]@{
                    Subscription   = $subName
                    ResourceGroup  = $nsg.ResourceGroupName
                    NSG            = $nsg.Name
                    RuleName       = $rule.Name
                    Priority       = $rule.Priority
                    Direction      = $rule.Direction
                    Access         = $rule.Access
                    Protocol       = $rule.Protocol
                    SourceAddress  = (($rule.SourceAddressPrefix + $rule.SourceAddressPrefixes) | Where-Object { $_ }) -join ', '
                    SourcePort     = (($rule.SourcePortRange + $rule.SourcePortRanges) | Where-Object { $_ }) -join ', '
                    DestAddress    = (($rule.DestinationAddressPrefix + $rule.DestinationAddressPrefixes) | Where-Object { $_ }) -join ', '
                    DestPort       = (($rule.DestinationPortRange + $rule.DestinationPortRanges) | Where-Object { $_ }) -join ', '
                    Description    = $rule.Description
                })
            }
        }
    }
    Write-Host " $(@($nsgs).Count)"

    # Public IPs --------------------------------------------------------------
    Write-Host "  public IPs..." -NoNewline
    $pips = Invoke-Safely -Subscription $subName -Area 'PublicIPs' -Script { Get-AzPublicIpAddress }
    foreach ($pip in $pips) {
        $results.PublicIPs.Add([pscustomobject]@{
            Subscription  = $subName
            ResourceGroup = $pip.ResourceGroupName
            Name          = $pip.Name
            Location      = $pip.Location
            IpAddress     = $pip.IpAddress
            Allocation    = $pip.PublicIpAllocationMethod
            Sku           = if ($pip.Sku) { $pip.Sku.Name } else { '' }
            Fqdn          = if ($pip.DnsSettings) { $pip.DnsSettings.Fqdn } else { '' }
            # The NIC (or gateway/load balancer) holding this IP. Blank means an
            # orphaned IP -- still billing, attached to nothing. Cross-reference
            # against VirtualMachines.csv NICs column to reach the VM itself.
            AttachedToResource = if ($pip.IpConfiguration) { ($pip.IpConfiguration.Id -split '/')[8] } else { '' }
            AttachedToType     = if ($pip.IpConfiguration) { ($pip.IpConfiguration.Id -split '/')[7] } else { '' }
        })
    }
    Write-Host " $(@($pips).Count)"

    # Private endpoints -------------------------------------------------------
    Write-Host "  private endpoints..." -NoNewline
    $pes = Invoke-Safely -Subscription $subName -Area 'PrivateEndpoints' -Script { Get-AzPrivateEndpoint }
    foreach ($pe in $pes) {
        $target = $pe.PrivateLinkServiceConnections | Select-Object -First 1
        $results.PrivateEndpoints.Add([pscustomobject]@{
            Subscription  = $subName
            ResourceGroup = $pe.ResourceGroupName
            Name          = $pe.Name
            Location      = $pe.Location
            Subnet        = if ($pe.Subnet) { ($pe.Subnet.Id -split '/')[-1] } else { '' }
            PrivateIPs    = ($pe.NetworkInterfaces | ForEach-Object { $_.Id }) -join ', '
            TargetResource= if ($target) { $target.PrivateLinkServiceId } else { '' }
            GroupIds      = if ($target) { $target.GroupIds -join ', ' } else { '' }
        })
    }
    Write-Host " $(@($pes).Count)"

    # Storage accounts --------------------------------------------------------
    Write-Host "  storage accounts..." -NoNewline
    $stores = Invoke-Safely -Subscription $subName -Area 'StorageAccounts' -Script { Get-AzStorageAccount }
    foreach ($sa in $stores) {
        $results.StorageAccounts.Add([pscustomobject]@{
            Subscription      = $subName
            ResourceGroup     = $sa.ResourceGroupName
            Name              = $sa.StorageAccountName
            Location          = $sa.Location
            Sku               = $sa.Sku.Name
            Kind              = $sa.Kind
            AccessTier        = $sa.AccessTier
            HttpsOnly         = $sa.EnableHttpsTrafficOnly
            MinimumTlsVersion = $sa.MinimumTlsVersion
            # Two fields worth reading together: public blob access and the
            # network default action tell you whether data is reachable openly.
            AllowBlobPublicAccess = $sa.AllowBlobPublicAccess
            NetworkDefaultAction  = if ($sa.NetworkRuleSet) { $sa.NetworkRuleSet.DefaultAction } else { '' }
            PublicNetworkAccess   = $sa.PublicNetworkAccess
            CreationTime      = $sa.CreationTime
        })
    }
    Write-Host " $(@($stores).Count)"

    # Virtual machines --------------------------------------------------------
    Write-Host "  virtual machines..." -NoNewline
    $vms = Invoke-Safely -Subscription $subName -Area 'VirtualMachines' -Script { Get-AzVM }
    foreach ($vm in $vms) {
        $img = $vm.StorageProfile.ImageReference
        $results.VirtualMachines.Add([pscustomobject]@{
            Subscription  = $subName
            ResourceGroup = $vm.ResourceGroupName
            Name          = $vm.Name
            Location      = $vm.Location
            Size          = $vm.HardwareProfile.VmSize
            OsType        = $vm.StorageProfile.OsDisk.OsType
            ImagePublisher= if ($img) { $img.Publisher } else { '' }
            ImageOffer    = if ($img) { $img.Offer } else { '' }
            ImageSku      = if ($img) { $img.Sku } else { '' }
            ImageVersion  = if ($img) { $img.ExactVersion } else { '' }
            OsDisk        = $vm.StorageProfile.OsDisk.Name
            DataDiskCount = @($vm.StorageProfile.DataDisks).Count
            NICs          = ($vm.NetworkProfile.NetworkInterfaces | ForEach-Object { ($_.Id -split '/')[-1] }) -join ', '
            Zones         = ($vm.Zones -join ', ')
            LicenseType   = $vm.LicenseType
            Tags          = if ($vm.Tags) { ($vm.Tags.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '; ' } else { '' }
        })
    }
    Write-Host " $(@($vms).Count)"

    # Managed disks -----------------------------------------------------------
    Write-Host "  disks..." -NoNewline
    $disks = Invoke-Safely -Subscription $subName -Area 'Disks' -Script { Get-AzDisk }
    foreach ($d in $disks) {
        $results.Disks.Add([pscustomobject]@{
            Subscription  = $subName
            ResourceGroup = $d.ResourceGroupName
            Name          = $d.Name
            Location      = $d.Location
            SizeGB        = $d.DiskSizeGB
            Sku           = if ($d.Sku) { $d.Sku.Name } else { '' }
            OsType        = $d.OsType
            # Unattached disks are the classic unnoticed spend.
            State         = $d.DiskState
            AttachedTo    = if ($d.ManagedBy) { ($d.ManagedBy -split '/')[-1] } else { '' }
            Encryption    = if ($d.Encryption) { $d.Encryption.Type } else { '' }
        })
    }
    Write-Host " $(@($disks).Count)"

    # Azure SQL ---------------------------------------------------------------
    Write-Host "  SQL servers..." -NoNewline
    $sqlServers = Invoke-Safely -Subscription $subName -Area 'SqlServers' -Script { Get-AzSqlServer }
    foreach ($srv in $sqlServers) {
        $results.SqlServers.Add([pscustomobject]@{
            Subscription        = $subName
            ResourceGroup       = $srv.ResourceGroupName
            Name                = $srv.ServerName
            Location            = $srv.Location
            FullyQualifiedName  = $srv.FullyQualifiedDomainName
            AdminLogin          = $srv.SqlAdministratorLogin
            Version             = $srv.ServerVersion
            PublicNetworkAccess = $srv.PublicNetworkAccess
            MinimalTlsVersion   = $srv.MinimalTlsVersion
        })

        # Databases per server. master is excluded -- it exists on every server
        # and carries no information about what is actually deployed.
        $dbs = Invoke-Safely -Subscription $subName -Area "SqlDatabases/$($srv.ServerName)" -Script {
            Get-AzSqlDatabase -ResourceGroupName $srv.ResourceGroupName -ServerName $srv.ServerName |
                Where-Object { $_.DatabaseName -ne 'master' }
        }
        foreach ($db in $dbs) {
            $results.SqlDatabases.Add([pscustomobject]@{
                Subscription   = $subName
                ResourceGroup  = $srv.ResourceGroupName
                Server         = $srv.ServerName
                Database       = $db.DatabaseName
                Status         = $db.Status
                Edition        = $db.Edition
                ServiceObjective = $db.CurrentServiceObjectiveName
                MaxSizeGB      = if ($db.MaxSizeBytes) { [math]::Round($db.MaxSizeBytes / 1GB, 2) } else { $null }
                ZoneRedundant  = $db.ZoneRedundant
                # Non-null means this is a replica of something else -- worth
                # knowing before treating it as a source of truth.
                CreateMode     = $db.CreateMode
                EarliestRestore= $db.EarliestRestoreDate
                CreationDate   = $db.CreationDate
            })
        }
    }
    Write-Host " $(@($sqlServers).Count)"

    # Other database platforms ------------------------------------------------
    # Queried generically via Get-AzResource so the script does not require the
    # Az.MySql / Az.PostgreSql / Az.CosmosDB modules to be installed.
    Write-Host "  other database resources..." -NoNewline
    $dbTypes = @(
        'Microsoft.DBforMySQL/servers',
        'Microsoft.DBforMySQL/flexibleServers',
        'Microsoft.DBforPostgreSQL/servers',
        'Microsoft.DBforPostgreSQL/flexibleServers',
        'Microsoft.DBforMariaDB/servers',
        'Microsoft.DocumentDB/databaseAccounts',
        'Microsoft.Sql/managedInstances',
        'Microsoft.Cache/Redis',
        'Microsoft.Synapse/workspaces'
    )
    $otherCount = 0
    foreach ($t in $dbTypes) {
        $found = Invoke-Safely -Subscription $subName -Area "OtherDatabases/$t" -Script {
            Get-AzResource -ResourceType $t
        }
        foreach ($r in $found) {
            $results.OtherDatabases.Add([pscustomobject]@{
                Subscription  = $subName
                ResourceGroup = $r.ResourceGroupName
                Name          = $r.Name
                Type          = $r.ResourceType
                Location      = $r.Location
                Sku           = if ($r.Sku) { $r.Sku.Name } else { '' }
            })
            $otherCount++
        }
    }
    Write-Host " $otherCount"
}

# --- output -----------------------------------------------------------------

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

Write-Step "`nWriting CSVs to $OutputPath"
foreach ($key in $results.Keys | Sort-Object) {
    $file = Join-Path $OutputPath "$key.csv"
    if ($results[$key].Count -gt 0) {
        $results[$key] | Export-Csv -Path $file -NoTypeInformation -Encoding UTF8
        Write-Host ("  {0,-18} {1,6} rows" -f $key, $results[$key].Count)
    } else {
        Write-Host ("  {0,-18} {1,6}" -f $key, 'none')
    }
}

# --- summary ----------------------------------------------------------------

Write-Step "`n=== Summary ===" 'Green'
[pscustomobject]@{
    Subscriptions    = $results.Subscriptions.Count
    ResourceGroups   = $results.ResourceGroups.Count
    VirtualNetworks  = $results.VirtualNetworks.Count
    Subnets          = $results.Subnets.Count
    Peerings         = $results.Peerings.Count
    NSGs             = $results.NSGs.Count
    PublicIPs        = $results.PublicIPs.Count
    PrivateEndpoints = $results.PrivateEndpoints.Count
    StorageAccounts  = $results.StorageAccounts.Count
    VirtualMachines  = $results.VirtualMachines.Count
    Disks            = $results.Disks.Count
    SqlServers       = $results.SqlServers.Count
    SqlDatabases     = $results.SqlDatabases.Count
    OtherDatabases   = $results.OtherDatabases.Count
    Errors           = $results.Errors.Count
} | Format-List

if ($results.Errors.Count -gt 0) {
    Write-Warning "$($results.Errors.Count) error(s) recorded. Review Errors.csv -- an empty category may mean 'no access' rather than 'none present'."
}

Write-Step "Done. Output: $OutputPath" 'Green'
