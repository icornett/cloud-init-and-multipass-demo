#!/bin/bash

set -e -o pipefail

if [ -z "$1" ]; then
  ARG1_DEFAULT="docker"
  echo "Using default value: $ARG1_DEFAULT"
  VM_NAME=$ARG1_DEFAULT
else
  VM_NAME=$1
fi

# Now do something with the argument
echo "Docker host name is $VM_NAME"

VM_IMAGE=remote:docker

if ! command -v multipass &> /dev/null
then
    echo "Multipass is not installed. Installing..."
    brew install multipass
    echo "Multipass installed successfully."
else
    echo "Multipass is already installed."
fi

if multipass list | grep -q $VM_NAME; then # Check if the VM exists
  STATUS=$(multipass info $VM_NAME | awk '/^State/ {print $2}') # Get the VM's status
  if [ "$STATUS" == "Stopped" ]; then # Check if the VM is stopped
    multipass start $VM_NAME # Start the VM
    echo "Docker Host $VM_NAME has been started."
  else
    echo "Docker Host $VM_NAME is already running."
  fi
else
    echo "Starting Docker Host $VM_NAME..."
    multipass launch remote:$VM_IMAGE --cpus 2 --memory 4G --disk 20G --timeout 600
fi

NEW_IP=$(multipass list --format csv | grep $VM_NAME | awk -F',' '{print $3}' | grep '^192')
echo $NEW_IP

sudo sed -i "$VM_NAME" "/$VM_NAME/d" /etc/hosts
sudo sh -c "echo '$NEW_IP $VM_NAME.local' >> /etc/hosts"


export DOCKER_HOST="tcp://$VM_NAME.local:2375"

multipass shell $VM_NAME