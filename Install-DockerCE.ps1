#! /usr/bin/env pwsh

[CmdletBinding()]
param (
    [Parameter(HelpMessage = 'The name of the VM to deploy', Position = 0)]
    [String]
    $VM_NAME = 'fakedocker'
)

$ErrorActionPreference = 'Stop'

# Check if the VM exists
if ((multipass list) -match $VM_NAME) {
    # Get the VM's status
    $STATUS = ((multipass info $VM_NAME) -match "^State").Split()[-1]
    if ($STATUS -eq "Stopped") {
        # Start the VM if it is stopped
        multipass start $VM_NAME
        Write-Host "VM $VM_NAME has been started."
    }
    else {
        Write-Host "VM $VM_NAME is already running."
    }
}
else {
    Write-Host "VM $VM_NAME doesn't exist."
}

# SSH into the VM as docker user
$env:DOCKER_HOST = "tcp://$VM_NAME.local:2375"
ssh -o StrictHostKeyChecking=no docker@$VM_NAME.local