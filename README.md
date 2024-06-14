# ps-k8s
Ansible playbooks to create infrastructure for the Pluralsiight Certified Kubernetes Administrator path using either proxmox or virtualbox

**THIS IS A WORK IN PROGESS - DO NOT USE**


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