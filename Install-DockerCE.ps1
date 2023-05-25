#! /usr/bin/env pwsh

[CmdletBinding()]
param (
    [Parameter(HelpMessage = 'The name of the docker host')]
    [String]
    $VM_NAME = 'docker'
)

$VM_IMAGE = 'docker'

$ErrorActionPreference = 'Stop'

if ((Get-Command multipass -ErrorAction SilentlyContinue) -eq $null) {
    Write-Host "Multipass is not installed. Installing..."
    try {
        if ($PSVersionTable.PSEdition -eq 'Desktop' -and $PSVersionTable.OS -match 'Windows') {
            Write-Host "Operating system is Windows."
            winget install Canonical.Multipass
        }
        else {
            Write-Host "Operating system is not Windows."
            brew install multipass
        }
        Write-Host "Multipass installed successfully."
    }
    catch {
        Write-Error "Could not install Multipass"
        throw
    }
}
else {
    Write-Host "Multipass is already installed."
}

# Check if the VM exists
if ((multipass list) -match $VmName) {
    # Get the VM's status
    $STATUS = ((multipass info $VM_NAME) -match "^State").Split()[-1]
    if ($STATUS -eq "Stopped") {
        # Start the VM if it is stopped
        multipass start $VM_NAME
        Write-Host "Docker Host $VM_NAME has been started."
    }
    else {
        Write-Host "Docker Host $VM_NAME is already running."
    }
}
else {
    Write-Host "Docker Host $VM_NAME doesn't exist."
    multipass launch remote:$VM_IMAGE --name  $VM_NAME --cpus 2 --memory 4G --disk 20G --timeout 600
}

$IP_ADDRESS = (multipass list --format csv | Select-String $VM_NAME | ForEach-Object { ($_ -split ',')[2] } | Select-String '^192')


(Get-Content -Path C:\Windows\System32\drivers\etc\hosts) | Where-Object { $_ -notmatch "$VM_NAME" } | Set-Content -Path C:\Windows\System32\drivers\etc\hosts
Write-Output "$IP_ADDRESS $VM_NAME.local" | Out-File -Append -FilePath C:\Windows\System32\drivers\etc\hosts

$env:DOCKER_HOST = "tcp://$VM_NAME.local:2376"

multipass shell $VM_NAME