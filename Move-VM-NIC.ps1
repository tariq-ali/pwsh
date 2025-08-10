#!/usr/bin/env pwsh
# Requires VMware PowerCLI
# Install with: Install-Module -Name VMware.PowerCLI -Scope CurrentUser

# --- Variables ---
$vcenterServer = "dc1-vcenter.fedcivlab.ciscolabs.com"
$vcenterUser   = "taali@fedcivlab.ciscolabs.com"
$vcenterPass   = "FEDciv123!"

# Path to CSV file (adjust if needed)
$vmListCsv = "$HOME/Code/powershell/vm.csv"

# --- Connect to vCenter ---
Write-Host "Connecting to vCenter $vcenterServer..." -ForegroundColor Cyan
Connect-VIServer -Server $vcenterServer -User $vcenterUser -Password $vcenterPass

# --- Import VM list ---
$vmList = Import-Csv -Path $vmListCsv

foreach ($entry in $vmList) {
    $vmName = $entry.VMName
    $newNetwork = $entry.NetworkName

    # Get VM
    $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
    if (-not $vm) {
        Write-Warning "VM '$vmName' not found. Skipping."
        continue
    }

    # Get the first (only) NIC
    $adapter = Get-NetworkAdapter -VM $vm | Select-Object -First 1
    if (-not $adapter) {
        Write-Warning "No network adapter found for '$vmName'. Skipping."
        continue
    }

    # Change the NIC network
    Write-Host "Changing '$vmName' NIC '$($adapter.Name)' to '$newNetwork'..." -ForegroundColor Yellow
    Set-NetworkAdapter -NetworkAdapter $adapter -NetworkName $newNetwork -Confirm:$false -WhatIf

    Write-Host "VM '$vmName' updated to '$newNetwork'." -ForegroundColor Green
}

# --- Disconnect ---
Disconnect-VIServer -Server $vcenterServer -Confirm:$false
Write-Host "All done." -ForegroundColor Cyan
