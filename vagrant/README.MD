# Usage
 
 ## Preparation
 - Install [vagrant](https://developer.hashicorp.com/vagrant/docs/installation) 
 - Edit the machines.txt file and set the IP addresses you would like to use.
 - The user.txt file contains the user account name - if you chose to change this, you will also need to update ansible_user in host_vars or `group_vars/all.yml` There may be other places - search he codebase for `psight`
 - Due to how vagrant works, it will create a NAT network for it's own use and make this the default route. This messes up the default Kubernetes API Server endpoint as it is based on the default route. I have attempted to fix this but the provisioning process resets it. A less than ideal solution for now is to use a separate inventory file and set the k8s_api_ip variable to the same IP you set in machines.txt
 - if you do not have an SSH key on your workstation, [create an RSA key pair](https://www.ssh.com/academy/ssh/keygen). If it is not called "id_rsa.pub", then you will need to update the Vagrantfile accordingly.
 - Add entries for your VMs in your hosts file as per the instruction in the root README oof this repo

## Provisioning
 - Run `vagrant up` to provision the boxes. I found that if I tried to bring all the boxes up at once, i got timeouts so you might want to bring them up one or two at a time with "vagrant up x y z".
 - You should be able to run `ssh psight@c1-cp1`  - yiu should do this for each host to accept the fingerprint
 - If you are struggling with memory, you can reduce the memory in the Vagrantfile but you may struggle if you deploy a lot of pods to your cluster.

# Managing the boxes
 - You can stop and start the boxes from either the VirtualBox UI or with  `vagrant halt` and `vagrant up` commands.
 - Run `vagrant destroy` to decommission the boxes.
  