#!/bin/bash

action=${1:-}
shift || true

CONFIG=~/.config/proxk8s.json
PROXMOX_HOST=pve1
PROXMOX_NODE=pve1

KEY_FILE=""
REBOOT="false"
RESET_KEYS="false"

# Parse extra flags (used by 'keys')
while [[ $# -gt 0 ]]; do
    case "$1" in
        --keyfile)
            KEY_FILE="${2:?--key-file needs a path}"
            shift 2
        ;;
        --reboot)
            REBOOT="true"
            shift
        ;;
        --reset)
            RESET_KEYS="true"
            shift
        ;;
        --) # end of options
            shift
            break
        ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 2
        ;;
        *)  # first positional arg -> stop parsing flags
            break
        ;;
    esac
done

usage() {
    echo "Usage: $0 start|stop|destroy|create|keys [--keyfile PATH] [--reboot] [--reset]"
    exit 1
}

# Validate action
case "$action" in
    start|stop|destroy|create|keys) ;;
    *) usage ;;
esac


# if action is destroy, ask user to confirm by typing "DESTROY"
if [ "$action" == "destroy" ]; then
    echo "Are you sure you want to destroy all VMs? Type DESTROY to confirm."
    read -r confirm
    if [ "$confirm" != "DESTROY" ]; then
        echo "Exiting."
        exit 1
    fi
fi

gw=$(jq -r '.gateway' $CONFIG)
nameserver=$(jq -r '.nameserver' $CONFIG)

template_id=$(jq -r '.["proxmox-template-id"]' $CONFIG)
vm=$(jq -r '.["proxmox-base-vm-id"]' $CONFIG)

length=$(jq '.machines | length' $CONFIG)
for (( i=0; i<$length; i++ ))
do
    name=$(jq -r ".machines[$i].name" $CONFIG)
    ip=$(jq -r ".machines[$i].ip" $CONFIG)
    
    
    case $action in
        start)
            echo "Starting host $name (vm $vm)"
            # shellcheck disable=SC2029
            ssh root@$PROXMOX_HOST "qm start $vm"
        ;;
        stop)
            echo "Stopping host $name (vm $vm)"
            # shellcheck disable=SC2029
            ssh root@$PROXMOX_HOST "qm stop $vm"
        ;;
        destroy)
            echo "Destroying host $name (vm $vm)"
            # shellcheck disable=SC2029
            ssh root@$PROXMOX_HOST "qm stop $vm"
            ssh root@$PROXMOX_HOST "qm destroy $vm"
            ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$name"
        ;;
        create)
            echo "Creating vm $vm from template $template_id for $name"
            # shellcheck disable=SC2029
            ssh root@$PROXMOX_HOST "pvesh create /nodes/pve1/qemu/${template_id}/clone --newid ${vm} --full --name ${name}"
            
            echo  "Setting IP  $ip with gateway $gw for host $name"
            # shellcheck disable=SC2029
            ssh root@$PROXMOX_HOST "qm set $vm --ipconfig0 ip=$ip/24,gw=$gw"
            
            echo "Setting nameserver for $name"
            ssh root@$PROXMOX_HOST "qm set $vm --nameserver ${nameserver}"
            
            echo "Starting host $name (vm $vm)"
            # shellcheck disable=SC2029
            ssh root@$PROXMOX_HOST "qm start $vm"
        ;;
        
        keys)
            echo "Setting SSH key(s) for cloud-init for $name (vm $vm)"
            if [ "$RESET_KEYS" = "true" ]; then
                # Replace all existing keys with the new key(s)
                tmp_merged="$(mktemp)"
                cat "$KEY_FILE" | tr -d '\r' | awk 'NF{ if(!seen[$0]++) print $0 }' > "$tmp_merged"
            else
                # 1) Read existing sshkeys from Proxmox API
                existing_keys_enc="$(ssh -o BatchMode=yes root@"$PROXMOX_HOST" \
                "pvesh get /nodes/$PROXMOX_NODE/qemu/$vm/config --output-format json" \
                | jq -r '.sshkeys // ""')"

                # URL-decode: turn %xx into bytes (handles %0A → newline etc.)
                existing_keys_decoded="$(printf '%b' "${existing_keys_enc//%/\\x}")"

                tmp_merged="$(mktemp)"
                {
                    [ -n "$existing_keys_decoded" ] && printf '%s\n' "$existing_keys_decoded"
                    cat "$KEY_FILE"
                } | tr -d '\r' | awk 'NF{ if(!seen[$0]++) print $0 }' > "$tmp_merged"
            fi

            # 3) Ship merged to Proxmox and set it
            remote_tmp="/tmp/ci_sshkeys_${vm}.pub"
            scp -q "$tmp_merged" root@"$PROXMOX_HOST":"$remote_tmp"
            rm -f "$tmp_merged"

            ssh -o BatchMode=yes root@"$PROXMOX_HOST" "qm set $vm --sshkey $remote_tmp && rm -f $remote_tmp"

            # 4) Optionally reboot to apply immediately
            if [ "$REBOOT" = "true" ]; then
                if ssh -o BatchMode=yes root@"$PROXMOX_HOST" "qm status $vm | grep -q running"; then
                    echo "Rebooting $name (vm $vm) to apply keys"
                    ssh -o BatchMode=yes root@"$PROXMOX_HOST" "qm reboot $vm"
                else
                    echo "$name (vm $vm) is powered off; keys will apply on next boot."
                fi
            fi
        ;;
    esac
    # end switch
    
    vm=$((vm+1))
done

