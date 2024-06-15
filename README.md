# ps-k8s
Ansible playbooks to create infrastructure for the Pluralsiight Certified Kubernetes Administrator path using either proxmox or virtualbox.

It will help you tpo provision the c1-cp1 control plane node, teh 3 worker nodes (c1-node1, c1-node2 and c1-node3) and the c1-storage nodes used by the course.

I recommend that you fork this repo so you can customize and preserve your configuration for future use.

**THIS IS A WORK IN PROGRESS - DO NOT USE YET**


## Prerequisites
 - A virtualization platform - this repo will include a proxmox template and a vagrant Vagrantfile for Oracle Virtual Box
 - A machine capable of running Ansible (Microsoft windows is problematic - either dual boot to a Linux Distro or create a workstation in VirtualBox - Linux Mint is a good Windows like distro for building a workstation)
 - If you are using **VirtualBox**, install [vagrant](https://developer.hashicorp.com/vagrant/install?product_intent=vagrant) from Hashicorp then you can simply follow the instructions in the `vagrant` folder to provision the necessary machines.
 - If you are using **proxmox**, create the following machines from a Ubuntu template (an Ansible playbook to build a Ubuntu 24.04 cloud-init server template is included). If you build the recommended template, the only thing you will need to change when cloning is the hostname and the ip address.
    - c1-cp1 - this will be the control plane
    - c1-node1 - worker node 1
    - c1-node2 - worker node 1
    - c1-node3 - worker node 1
    - c1-storage - used late in the course for the lessons on stateful sets and persistent storage
- If you are using a different virtual machine platform, you will need to build the boxes yourself. The recommendation is to use a Ubuntu base image. Each virtual machine should have the following specs:
    -  minimum of 2 cpu cores, 
    - at least 8GB Ram 
    - 50GB disk (I think the course recommends 30 but you'll want some headroom for experimentation)
    - a static IP (either on the VM itself or via assigning the mac addresses fixed IPs in the DHCP settings on your router)
    - a user `psight` with `sudo` access and preferably with NOPASSWD set (`sudo visudo` the add the line `psight ALL=(ALL) NOPASSWD: ALL`). If you do not wish to use `psight` as your user, please mentally adjust as you read these instructions - and you may need to modify some variables in the playbooks/templates.    
- Add the ip addresses for the hostnames listed above to your hosts file (`/etc/hosts` on Linux or `c:\Windows\System32\Drivers\etc\hosts` on Windows). You will need to run your editor with elevated permissions ("sudo" or "run as admin") when editing your hosts file
- I recommend using VSCode on your workstation (and possibly on the control plane) as the labs on the course are presented using VSCode and it may be easier to follow along. The "remote SSH" extension will allow you to run vscode on any of the nodes. The nodes will also have nano, vi and vim available if you prefer not to use vscode.
- From your workstation, confirm that you can run `ssh psight@c1-cp1` without requiring a password, and once connected, that you can run `sudo echo hello` without prompting for a password - this will simplify running the Ansible plays.
- repeat above tests for `c1-node1`, `c1-node2`, `c1-node3` and `c1-storage`.
- **ssh onto each node once before running the playbooks to ensure you have the fingerprint in known_hosts**

## Running the Ansible Playbooks

Firstly, check that Ansible can reach your nodes. If you have changed the user on the nodes, edit the `course_infrastrucure/group-vars/all.yml` file to reflect the correct user.
from the `course_infrastructure` folder, run the following command: 

```bash
ansible all -m ping
```

If all is well, you will see green "pong" messages from each of the nodes and you can continue with the playbooks.


## roadmap
 - script or add instructions for provisioning proxmox instances
 - vagrant - create ubuntu box with ansible and publish. Add a vagrantfile to start VMs
 - setting static IPs - either in the vm config or router DHCP fixed address
 - create inventory file for control plane, worker nodes and storage nod
 - create roles
    - base role for everything common to all machines
    - options to use calico or flannel for CNI
    - cp role
    - worker nodes role
    - storage role
- write docs, including instructions for windows hosts.
