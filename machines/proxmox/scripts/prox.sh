#!/bin/bash

action=$1

# action must be start, stop,destroy or create. If not set to one of these values, exit with an error.
if [ "$action" != "start" ] && [ "$action" != "stop" ] && [ "$action" != "destroy" ] && [ "$action" != "create" ]; then
    echo "Usage: $0 start|stop|destroy|create"
    exit 1
fi

# if action is destroy, ask user to confim by typing "DESTROY"
if [ "$action" == "destroy" ]; then
    echo "Are you sure you want to destroy all VMs? Type DESTROY to confirm."
    read -r confirm
    if [ "$confirm" != "DESTROY" ]; then
        echo "Exiting."
        exit 1
    fi
fi

gw=$(jq -r '.gateway' config.json)
template_id=$(jq -r '.["proxmox-template-id"]' config.json)
vm=$(jq -r '.["proxmox-base-vm-id"]' config.json)

length=$(jq '.machines | length' config.json)
for (( i=0; i<$length; i++ ))
do
    name=$(jq -r ".machines[$i].name" config.json)
    ip=$(jq -r ".machines[$i].ip" config.json)

    
    case $action in 
        start)
            echo "Starting host $name (vm $vm)"
            # shellcheck disable=SC2029
            ssh root@proxmox "qm start $vm"
            ;;
        stop)
            echo "Stopping host $name (vm $vm)"
            # shellcheck disable=SC2029
            ssh root@proxmox "qm stop $vm"
            ;;
        destroy)
            echo "Destroying host $name (vm $vm)"
            # shellcheck disable=SC2029
            ssh root@proxmox "qm stop $vm"
            ssh root@proxmox "qm destroy $vm"
            ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$name"
            ;;
        create)
            echo "Creating vm $vm from template $template_id for $name"
            # shellcheck disable=SC2029
            ssh root@proxmox "pvesh create /nodes/pve1/qemu/${template_id}/clone --newid ${vm} --full --name ${name}"

            echo  "Setting IP  $ip with gateway $gw for host $name"
            # shellcheck disable=SC2029
            ssh root@proxmox "qm set $vm --ipconfig0 ip=$ip/24,gw=$gw"

            echo "Starting host $name (vm $vm)"
            # shellcheck disable=SC2029
            ssh root@proxmox "qm start $vm"
            ;;
    esac
    # end switch

    vm=$((vm+1))
done

