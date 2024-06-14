# Create proxmox template 

This playbook will create a proxmox template based on ubuntu 24.04 server edition.

It is based on James Rhooat's [youtube video](https://www.youtube.com/watch?v=lO714Bk0tV4) and associated [repo](https://github.com/Rhoat/ansibleRole-proxmox-templates)


# Usage
 - modify the inventory file to use your own proxmox host.
 - Ensure your ssh keys are installed on the proxmox host and that you can 'ssh root@<your host>'
 - Test that Ansible can reach your host with `ansible proxmox -m ping`. If successful, you should see a green 'pong' response. If you require a password for ssh authentication, add the --ask-pass parameter.
 - edit the roles/proxmox-template/vars/main.template file - in particular, `ciuser`, `ipconfig0` and `sshkey` (update sshkey if you do not use the standard id_rsa name for your key). You may need to edit the name of the ipconfig0 variable if you wish to use a different network interface. 
 - If you wish to use a different cloud-init image, add or edit the cloudimgs variable
 - TODO create your own version of .vault file - that contains your ssh public key