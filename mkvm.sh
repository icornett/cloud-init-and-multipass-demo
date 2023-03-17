#!/bin/zsh
VM_NAME=$1
/usr/local/bin/multipass launch -n $VM_NAME --cloud-init ./cloud-init-multipass.yml
/usr/bin/ssh ubuntu@$VM_NAME.local