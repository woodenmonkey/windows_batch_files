# Azure tenant discovery

Read-only inventory script. Enumerates every subscription the signed-in account
can see and writes one CSV per resource category.

Every call is a GET. The script creates, modifies, and deletes nothing.

## Prerequisites

```powershell
Install-Module Az -Scope CurrentUser -Repository PSGallery
```

Reader at subscription scope is sufficient for everything here. No write
permission is required or used.

## Run

```powershell
# Whole tenant
.\Invoke-AzureDiscovery.ps1 -TenantId '00000000-0000-0000-0000-000000000000'

# Already connected, and include NSG rule detail
.\Invoke-AzureDiscovery.ps1 -SkipLogin -IncludeNsgRules

# Specific subscriptions, custom output location
.\Invoke-AzureDiscovery.ps1 -SubscriptionId 'sub-guid-1','sub-guid-2' -OutputPath C:\discovery
```

Output lands in a timestamped folder unless `-OutputPath` says otherwise.

## Parameters

| Parameter | Effect |
|---|---|
| `-TenantId` | Tenant to connect to. |
| `-SubscriptionId` | Limit to specific subscriptions. Omit for all visible. |
| `-OutputPath` | Where CSVs are written. Created if missing. |
| `-SkipLogin` | Use the existing Az context instead of prompting. |
| `-IncludeNsgRules` | Also enumerate individual NSG rules. Off by default — one extra call per NSG and the output is long. |

## Output

| File | Contents |
|---|---|
| `Subscriptions.csv` | Name, id, tenant, state |
| `ResourceGroups.csv` | Name, location, tags |
| `VirtualNetworks.csv` | Address space, DNS servers, subnet count |
| `Subnets.csv` | Prefix, attached NSG, route table, delegations, service endpoints, device count |
| `Peerings.csv` | Local/remote VNet, state, forwarded-traffic and gateway-transit flags |
| `NSGs.csv` | Rule count, attached subnets and NICs |
| `NSGRules.csv` | Custom rules only, with `-IncludeNsgRules` |
| `PublicIPs.csv` | Address, SKU, allocation, FQDN, what it's attached to |
| `PrivateEndpoints.csv` | Subnet, target resource, group ids |
| `StorageAccounts.csv` | SKU, kind, TLS floor, public blob access, network default action |
| `VirtualMachines.csv` | Size, OS, image reference, disks, NICs, tags |
| `Disks.csv` | Size, SKU, state, attachment, encryption |
| `SqlServers.csv` | FQDN, admin login, public network access, TLS floor |
| `SqlDatabases.csv` | Edition, service objective, size, create mode |
| `OtherDatabases.csv` | MySQL, PostgreSQL, MariaDB, Cosmos, Managed Instance, Redis, Synapse |
| `Errors.csv` | Anything that failed, with subscription and area |

## Read Errors.csv first

The script degrades rather than fails: a subscription or resource type the
account can't read is recorded and the run continues. **An empty CSV means
"none found OR not readable."** Check `Errors.csv` before concluding a resource
type is absent from the tenant.

This matters most on a tenant where access is resource-scoped rather than
subscription-scoped — resources can be invisible to enumeration while still
being referenced by ID from resources you *can* see.

## Notes

- `master` is excluded from `SqlDatabases.csv`; it exists on every server and
  says nothing about what's deployed.
- Default NSG rules are excluded from `NSGRules.csv` — they're identical
  everywhere and would bury the ones somebody actually wrote.
- Non-SQL database platforms are queried via `Get-AzResource`, so the
  `Az.MySql` / `Az.PostgreSql` / `Az.CosmosDB` modules aren't required.
- `Peerings.csv` is usually the most useful single artifact when mapping an
  unfamiliar estate — it shows where the network actually reaches, including
  into subscriptions the account may not be able to enumerate.
- Blank `AttachedToResource` in `PublicIPs.csv` means an orphaned public IP:
  still billing, attached to nothing.
- Unattached entries in `Disks.csv` are the classic unnoticed spend.

## Scope

Covers resource groups, networking, storage, compute, and databases as asked.
Not covered: App Service, AKS, Key Vault, Data Factory, Log Analytics,
Automation Accounts, role assignments. Adding a category is a new `dbTypes`-
style entry or a new collector block — the per-subscription loop and error
handling are already there.
