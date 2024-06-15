# ps-k8s
Ansible playbooks to create infrastructure for the Pluralsiight Certified Kubernetes Administrator path using either proxmox or virtualbox.

It will help you tpo provision the c1-cp1 control plane node, teh 3 worker nodes (c1-node1, c1-node2 and c1-node3) and the c1-storage nodes used by the course.

**THIS IS A WORK IN PROGESS - DO NOT USE YET**


## Prerequisites
 - A virtualization platform - this repo will include a proxmox template and a vagrant Vagrantfile for Oracle Virtual Box
 - A machine capable of running Ansible (Microsoft windows is problematic - either dual boot to a Linux Distro or create a workstaion in VirttualBox - Linux Mint is a good Windows ;like workstation)
 - If you are using **VirtualBox**, install [vagrant](https://developer.hashicorp.com/vagrant/install?product_intent=vagrant) from Hashicorp then you can simply follow the instructions in the `vagrant` folder to provision the necessary machines.
 - If you are using **proxmox**, create the following machines from a Ubuntu template (an Ansible playbook to build a Unbuntu 24.04 cloud-init server template is included). If you build the recommended tenplate, the only thing you will need to change when cloning is the hostname and the ip address.
    - c1-cp1 - this will be the control plane
    - c1-node1 - worker node 1
    - c1-node2 - worker node 1
    - c1-node3 - worker node 1
    - c1-storage - used late in the course for the lessons on stateful sets and persistent storage
- If you are using a different virtual machine platform, you will need to build the boxes yourself. The recommendation is to use Ubuntu, each machine should have the following specs:
    -  minimum of 2 cpu cores, 
    - at least 8GB Ram 
    - 50GB disk (I think the course recommends 30 but you'll want some headroom for experimentation)    
- Add the ip addresses for the hostnames listed above to your hosts file (`/etc/hosts` on Linux or `c:\Windows\System32\Drivers\etc\hosts` on windoows). You will need to run your 

## Running the playbooks

## roadmap
 - script or add instrcutions for provisioning proxmox instances
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