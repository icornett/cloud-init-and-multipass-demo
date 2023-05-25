#!/bin/bash

set -e -o pipefail

# Check if an argument was provided, if not use default value
if [ -z "$1" ]; then
  ARG1_DEFAULT="fakedocker"
  echo "Using default value: $ARG1_DEFAULT"
  VM_NAME=$ARG1_DEFAULT
else
  VM_NAME=$1
fi

if multipass list | grep -q $VM_NAME; then # Check if the VM exists
  STATUS=$(multipass info $VM_NAME | awk '/^State/ {print $2}') # Get the VM's status
  if [ "$STATUS" == "Stopped" ]; then # Check if the VM is stopped
    multipass start $VM_NAME # Start the VM
    echo "VM $VM_NAME has been started."
  else
    echo "VM $VM_NAME is already running."
  fi
else
    echo "Starting Docker Host $VM_NAME..."
    multipass launch --name $VM_NAME --cloud-init ./cloud-init-multipass.yml --cpus 2 --memory 4G --disk 20G
fi


export DOCKER_HOST="tcp://$VM_NAME.local:2375"

/usr/bin/ssh docker@$VM_NAME.local