# Create proxmox template 

This playbook will create a proxmox VM template based on ubuntu 24.04 server edition.

It is based on James Rhooat's [youtube video](https://www.youtube.com/watch?v=lO714Bk0tV4) and associated [repo](https://github.com/Rhoat/ansibleRole-proxmox-templates).

I have amended the role to fix all the ansible-lint issues (except the dynamic fact name) and amended it to suit the needs of this project. The created template will have a static IP, and will have ansible installed for flexibility in spinning up the Kubernetes infrastructure later. I have set the user to `psight`

**Note: This is a one-off playbook, it is NOT idempotent. Each run will create a new template.**

# Usage
 - Modify the inventory file to use your own proxmox host.
 - Ensure your ssh keys are installed on the proxmox host and that you can 'ssh root@your.proxmox.host'
 - Test that Ansible can reach your host with `ansible proxmox -m ping`. If successful, you should see a green 'pong' response. If you require a password for ssh authentication, add the --ask-pass parameter.
 - Edit the roles/proxmox-template/vars/main.template file - in particular, `ciuser`, `ipconfig0` and `sshkey` (update sshkey if you do not use the standard id_rsa name for your key). You may need to edit the name of the ipconfig0 variable if you wish to use a different network interface. 
 - If you wish to use a different cloud-init image, edit the cloudimg variable

 ## Creating and managing VMs

 There are some convenience scripts in the `machines/proxmox/scripts` folder. To use these you will first need to edit `machines/proxmox/scripts/config.json` to configure your proxmox template Id, the starting Id for the VMs and the gateway/ip addresses to suitable values for you. You will also need to install [jq](https://jqlang.github.io/jq/download/) if you do not already have it.

 Now you can do the following commands to manage your VMs:
  - `prox.sh create`
  - `prox.sh start`
  - `prox.sh stop`
  - `prox.sh destroy` (requires you tto type "DESTROY" to confirm)
