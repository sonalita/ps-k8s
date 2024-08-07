#!/bin/bash
set -x

vmid=$1
ipconfig=$2
nameserver=$3
sshkey=$4
ciuser=$5
dataStore=$6
img=$7


# if ide2 is already set to cloudinit, skip
config_output=$(qm config "$vmid")
if [[ $config_output =~ "ide2" ]]; then
  echo "Skipping."
else
  qm set "$vmid" --ide2 "$dataStore":cloudinit
fi

# if scsi0 is already set to vm-$vmid-disk-0, skip
# shellcheck disable=SC2076
if [[ $config_output =~ "scsi0: $dataStore:vm-$vmid-disk-0" ]]; then
  echo "Skipping."
else
    qm set "$vmid" --scsihw virtio-scsi-pci --scsi0 "$dataStore":0,import-from="$img" 
fi

# if cloudinit location is already set, skip
# shellcheck disable=SC2076
if [[ $config_output =~ "$dataStore:vm-$vmid-cloudinit" ]]; then
  echo "Skipping."
else
  qm set "$vmid" --ide2 "$dataStore":cloudinit
fi

# configure serial console if not set
if [[ $config_output =~ "serial0" ]]; then
  echo "Skipping."
else
  qm set "$vmid" --serial0 socket --vga serial0
fi

qm set "$vmid" --agent=1
qm set "$vmid" --sshkey "$sshkey"
qm set "$vmid" --ciuser="$ciuser"
qm set "$vmid" --ipconfig0 "$ipconfig"
qm set "$vmid" --boot c --bootdisk scsi0
qm set "$vmid" --autostart=1
qm set "$vmid" --onboot=1
qm set "$vmid" --nameserver "$nameserver"


