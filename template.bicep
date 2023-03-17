param virtualMachines_vm_cloudinit_demo_name string = 'vm-cloudinit-demo'
param storageAccounts_stslalomcloudinit_name string = 'stslalomcloudinit'
param sshPublicKeys_vm_cloudinit_demo_key_name string = 'vm-cloudinit-demo_key'
param networkInterfaces_vm_cloudinit_demo859_name string = 'vm-cloudinit-demo859'
param publicIPAddresses_vm_cloudinit_demo_ip_name string = 'vm-cloudinit-demo-ip'
param virtualNetworks_vm_cloudinit_demo_vnet_name string = 'vm-cloudinit-demo-vnet'
param networkSecurityGroups_vm_cloudinit_demo_nsg_name string = 'vm-cloudinit-demo-nsg'

resource sshPublicKeys_vm_cloudinit_demo_key_name_resource 'Microsoft.Compute/sshPublicKeys@2022-11-01' = {
  name: sshPublicKeys_vm_cloudinit_demo_key_name
  location: 'westus'
  properties: {
    publicKey: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCk4KaJWaDq/xLOlOTE2IcNE8mAx0NXxc6AkN9GB8J3ePWl0RkWXWor+otswCBsI1hn1MU2qczHYvMCsvLuMMKdxSlSR6GbZ/0TO+UPvwiHtqhgZ1xkhDQN7/LN4VpuJKTm5SYrxv+DWRROlizktBcOchiADUeLrapkEgnMUcnp7g76FfI2VLLB5M2at4TLRVtOK9M0+JQA4gQWPKA3uHBPGNFhnCEtLMbS5Yg7eeR09aDxCV/aozMMzcKA6ou99rtSnGr8nqj3eA0v5GULLdIhdALkwmS/W43E+ZTTsgmUvACuuPoW0C3hN9pxSd/43jJ9cgYJ9YIe7m7qtFl1lJOskVAiCFR2oYT74zLWniJhmo9svtuPApqzcNdmBc02ppGa3Yeff0D1WShEJKnFVKF4MtYP66BVB7hszujbTIZ/FRRxjpgNlTnoY1NLTWYziZgU99ySU9wGqiOcAso7w4AY1WIn9+7UYPhURyLylODKn3t8nGNVYvtllKa7HUSfyYU= generated-by-azure'
  }
}

resource publicIPAddresses_vm_cloudinit_demo_ip_name_resource 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: publicIPAddresses_vm_cloudinit_demo_ip_name
  location: 'westus'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: virtualMachines_vm_cloudinit_demo_name
  location: 'westus'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        diffDiskSettings: {
          option: 'Local'
          placement: 'CacheDisk'
        }
        createOption: 'FromImage'
        caching: 'ReadOnly'
        deleteOption: 'Delete'
        diskSizeGB: 30
      }
      dataDisks: []
    }
    osProfile: {
      computerName: virtualMachines_vm_cloudinit_demo_name
      adminUsername: 'azureuser'
      customData: loadFileAsBase64('./cloud-init.yml')
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureuser/.ssh/authorized_keys'
              keyData: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCk4KaJWaDq/xLOlOTE2IcNE8mAx0NXxc6AkN9GB8J3ePWl0RkWXWor+otswCBsI1hn1MU2qczHYvMCsvLuMMKdxSlSR6GbZ/0TO+UPvwiHtqhgZ1xkhDQN7/LN4VpuJKTm5SYrxv+DWRROlizktBcOchiADUeLrapkEgnMUcnp7g76FfI2VLLB5M2at4TLRVtOK9M0+JQA4gQWPKA3uHBPGNFhnCEtLMbS5Yg7eeR09aDxCV/aozMMzcKA6ou99rtSnGr8nqj3eA0v5GULLdIhdALkwmS/W43E+ZTTsgmUvACuuPoW0C3hN9pxSd/43jJ9cgYJ9YIe7m7qtFl1lJOskVAiCFR2oYT74zLWniJhmo9svtuPApqzcNdmBc02ppGa3Yeff0D1WShEJKnFVKF4MtYP66BVB7hszujbTIZ/FRRxjpgNlTnoY1NLTWYziZgU99ySU9wGqiOcAso7w4AY1WIn9+7UYPhURyLylODKn3t8nGNVYvtllKa7HUSfyYU= generated-by-azure'
            }
          ]
        }
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
        enableVMAgentPlatformUpdates: false
      }
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_vm_cloudinit_demo859_name_resource.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: virtualNetworks_vm_cloudinit_demo_vnet_name
}

resource defaultSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: 'default'
  parent: vnet
  properties: {
    addressPrefix: '10.0.0.0/24'
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
        locations: [
          'westus'
        ]
      }
    ]
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    vnet
  ]
}

resource storageAccounts_stslalomcloudinit_name_resource 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccounts_stslalomcloudinit_name
  location: 'westus'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    isNfsV3Enabled: true
    isSftpEnabled: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    isHnsEnabled: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: defaultSubnet.id
          action: 'Allow'
          state: 'Succeeded'
        }
      ]
      ipRules: []
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource storageAccounts_stslalomcloudinit_name_default 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storageAccounts_stslalomcloudinit_name_resource
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: false
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 7
    }
  }
}

resource storageAccounts_stslalomcloudinit_name_default_nfs 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  parent: storageAccounts_stslalomcloudinit_name_default
  name: 'nfs'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'Container'
  }
  dependsOn: [

    storageAccounts_stslalomcloudinit_name_resource
  ]
}

resource networkInterfaces_vm_cloudinit_demo859_name_resource 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: networkInterfaces_vm_cloudinit_demo859_name
  location: 'westus'
  kind: 'Regular'
  properties: {
    dnsSettings: {
      dnsServers: []
    }
    enableIPForwarding: false
    disableTcpStateTracking: false
    nicType: 'Standard'
    ipConfigurations: [
      {
        name: 'nic-vm-cloudinit-demo'
        properties: {
          primary: true
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_vm_cloudinit_demo_ip_name_resource.id
          }
          subnet: {
            id: defaultSubnet.id
          }
        }
      }
    ]
  }
}
