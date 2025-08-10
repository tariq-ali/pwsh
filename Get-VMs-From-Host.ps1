#!/usr/bin/env pwsh
# Requires VMware PowerCLI
# Install with: Install-Module -Name VMware.PowerCLI -Scope CurrentUser

# --- Variables ---
$vcenterServer = "vcenter.domain.local"
$vcenterUser   = "administrator@vsphere.local"
$vcenterPass   = "YourPassword"   # Or use Read-Host for secure entry

# Prompt for ESXi host (can also hardcode here if preferred)
$targetHost    = Read-Host "Enter ESXi host name or IP"

# --- Connect to vCenter ---
Write-Host "Connecting to vCenter $vcenterServer..." -ForegroundColor Cyan
Connect-VIServer -Server $vcenterServer -User $vcenterUser -Password $vcenterPass

# --- Get VM names from the specified host ---
$vmList = Get-VMHost -Name $targetHost | Get-VM | Select-Object -ExpandProperty Name

# --- Output results ---
Write-Host "VMs on host '$targetHost':" -ForegroundColor Yellow
$vmList | ForEach-Object { Write-Host $_ -ForegroundColor Green }

# --- Optional: Export to CSV ---
$vmList | Export-Csv -Path "$HOME/Code/powershell/VMs_On_$($targetHost).csv" -NoTypeInformation

# --- Disconnect ---
Disconnect-VIServer -Server $vcenterServer -Confirm:$false
Write-Host "Done." -ForegroundColor Cyan
