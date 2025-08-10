#!/usr/bin/env pwsh
# Requires VMware PowerCLI
# Install with: Install-Module -Name VMware.PowerCLI -Scope CurrentUser


# --- Variables ---
$vcenterServer = "vcenter.domain.local"
$vcenterUser   = "administrator@vsphere.local"
$vcenterPass   = "YourPassword"   # Or use Read-Host for secure entry

# Prompt for ESXi host (can also hardcode here if preferred)
$targetHost    = Read-Host "Enter ESXi host name or IP"

# Path to your CSV file
$vmListCsv = "$HOME/Code/pwsh/vm.csv"

# --- Connect to vCenter ---
Write-Host "Connecting to vCenter server '$vcenterServer'..." -ForegroundColor Cyan
Connect-VIServer -Server $vcenterServer -User $vcenterUser -Password $vcenterPass

# --- Import VM list ---
$vmList = Import-Csv -Path $vmListCsv

foreach ($entry in $vmList) {
    $vmName    = $entry.VMName
    $newNetwork = $entry.NetworkName

    # Get VM and filter to target ESXi host
    $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue | Where-Object { $_.VMHost.Name -eq $targetHost }
    if (-not $vm) {
        Write-Warning "VM '$vmName' not found on host '$targetHost'. Skipping."
        continue
    }

    # Get the first (and only) NIC
    $adapter = Get-NetworkAdapter -VM $vm | Select-Object -First 1
    if (-not $adapter) {
        Write-Warning "No network adapter found for '$vmName'. Skipping."
        continue
    }

    # Change the NIC network
    Write-Host "Updating NIC '$($adapter.Name)' on VM '$vmName' (host '$targetHost') to network '$newNetwork'..." -ForegroundColor Yellow
    Set-NetworkAdapter -NetworkAdapter $adapter -NetworkName $newNetwork -Confirm:$false

    Write-Host "VM '$vmName' successfully updated to '$newNetwork'." -ForegroundColor Green
}

# --- Disconnect from vCenter ---
Disconnect-VIServer -Server $vcenterServer -Confirm:$false
Write-Host "All operations completed successfully for host '$targetHost'." -ForegroundColor Cyan
