#!/usr/bin/env pwsh
# Requires VMware PowerCLI
# Install with: Install-Module -Name VMware.PowerCLI -Scope CurrentUser

# --- Variables ---
$vcenterServer = "vcenter.domain.local"
$vcenterUser   = "administrator@vsphere.local"
$vcenterPass   = "YourPassword"   # Or use Read-Host for secure entry

# Prompt for ESXi host (can also hardcode here if preferred)
$targetHost    = Read-Host "Enter ESXi host name or IP"

# Output CSV file path
#$outputCsv = "$HOME/Code/VM_Networks.csv"

# --- Connect to vCenter ---
Write-Host "Connecting to vCenter $vcenterServer..." -ForegroundColor Cyan
Connect-VIServer -Server $vcenterServer -User $vcenterUser -Password $vcenterPass

# --- Get VMs and NIC network info ---
$vmData = Get-VMHost -Name $targetHost |
    Get-VM |
    Get-NetworkAdapter |
    Select-Object @{Name='VMName';Expression={$_.Parent.Name}},
                  @{Name='NetworkName';Expression={$_.NetworkName}}

# --- Export to CSV ---
$vmData | Export-Csv -Path "$HOME/Code/powershell/vms_on_$($targetHost).csv" -NoTypeInformation

Write-Host "Export complete. CSV saved to $outputCsv" -ForegroundColor Green

# --- Disconnect ---
Disconnect-VIServer -Server $vcenterServer -Confirm:$false
Write-Host "Done." -ForegroundColor Cyan
