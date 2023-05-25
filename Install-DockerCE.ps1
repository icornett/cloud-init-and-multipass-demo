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
        Write-Host "Docker Host $VM_NAME has been started."
    }
    else {
        Write-Host "Docker Host $VM_NAME is already running."
    }
}
else {
    Write-Host "Docker Host $VM_NAME doesn't exist."
    multipass launch --name $VM_NAME --cloud-init ./cloud-init-multipass.yml --cpus 2 --memory 4G --disk 20G --timeout 600
}

$env:DOCKER_HOST = "tcp://$VM_NAME.local:2375"
multipass mount $env:USERPROFILE ${$VM_NAME}:/home/docker

multipass shell $VM_NAME