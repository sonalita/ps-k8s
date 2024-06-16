# ps-k8s
Ansible playbooks to create the required infrastructure for the Pluralsight Certified Kubernetes Administrator path, including templates for creating nodes using either Proxmox or Virtualbox. 

The playbooks will provision the c1-cp1 control plane node, the 3 worker nodes (c1-node1, c1-node2 and c1-node3) and the c1-storage nodes used by the course.

I recommend that you fork this repo so you can customize and preserve your configuration for future use.

**I have not yet done the Vagrant stuff - but the playbooks are all working if you use the proxmox template or build your own VMs to the specs shown below.**

## Prerequisites
 - A virtualization platform - this repo will include a Proxmox template and (eventually) a Vagrant Vagrantfile for Oracle Virtual Box.
 - A machine capable of running Ansible (Microsoft windows is problematic - either dual boot to a Linux Distro or create a workstation in VirtualBox - Linux Mint is a good Windows-like distro for building a workstation)
 - If you are using **VirtualBox**, install [Vagrant](https://developer.hashicorp.com/vagrant/install?product_intent=vagrant) from Hashicorp then you can simply follow the instructions in the `vagrant` folder to provision the necessary machines.
 - If you are using **Proxmox**, create the following machines from a Ubuntu template (an Ansible playbook to build a Ubuntu 24.04 cloud-init server template is included - se the README in that folder). If you build the recommended template, the only thing you will need to change when cloning is the hostname and the ip address.
    - c1-cp1 - this will be the control plane
    - c1-node1 - worker node 1
    - c1-node2 - worker node 1
    - c1-node3 - worker node 1
    - c1-storage - used later in the course for the lessons on stateful sets and persistent storage
- If you are using a different virtual machine platform, you will need to build the boxes yourself. The recommendation is to use a Ubuntu base image. Each virtual machine should have the following specs:
    -  Minimum of 2 cpu cores, 
    - At least 8GB Ram 
    - 50GB disk (I think the course recommends 30 but you'll want some headroom for experimentation)
    - A static IP (either on the VM itself or via assigning the mac addresses fixed IPs in the DHCP settings on your router)
    - A user `psight` with `sudo` access and preferably with NOPASSWD set (`sudo visudo` the add the line `psight ALL=(ALL) NOPASSWD: ALL`). If you do not wish to use `psight` as your user, please mentally adjust as you read these instructions - and you may need to modify some variables in the playbooks/templates.    
- Add the ip addresses for the hostnames listed above to your hosts file (`/etc/hosts` on Linux or `c:\Windows\System32\Drivers\etc\hosts` on Windows). You will need to run your editor with elevated permissions ("sudo" or "run as admin") when editing your hosts file
- I recommend using VSCode on your workstation (and possibly on the control plane) as the labs on the course are presented using VSCode and it may be easier to follow along. The "remote SSH" extension will allow you to run vscode on any of the nodes. The nodes will also have nano, vi and vim available if you prefer not to use vscode.
- From your workstation, confirm that you can run `ssh psight@c1-cp1` without requiring a password, and once connected, that you can run `sudo echo hello` without being prompting for a password - this will simplify running the Ansible plays, and save you some typing during the course.
- Repeat the above tests for `c1-node1`, `c1-node2`, `c1-node3` and `c1-storage`.
- **ssh onto each node once before running the playbooks to ensure you have the fingerprint in your workstation's known_hosts file**

## Running the Ansible Playbooks

Firstly, check that Ansible can reach your nodes. If you have changed the user on the nodes, edit the `course_infrastructure/group-vars/all.yml` file to reflect the correct user.
from the `course_infrastructure` folder, run the following command: 

```bash
ansible all -m ping
```

If all is well, you will see green "pong" messages from each of the nodes and you can continue with the playbooks.

### variables you might want to change
 - in group_vars/all.yaml - Update the ansible_user if you are not using the psight user. Also check the Kubernetes major and minor versions.
 - if you chose to use different hostnames, update the `inventory` file

 ### Provisioning

 Just run `ansible-playbook site.yaml`

 ## Playbooks

 ### base

This role corresponds to the "PackageInstallation-containerd.sh" script in the /03/demos folder of the course exercise files. It does the following:

Please note the following:

 - Configures the kernel with the necessary network mods, and updates sysctl
 - Installs containerd and configures the cgroup settings correctly
 - Installs the Kubernetes packages for the version set in `group_vars/all.yaml` **Note: Part of the course covers upgrading your control plane so you should not install the very latest version**

Note the following differences between the playbook and the exercise steps:

- Swap is already disabled in the proxmox template/vagrant box
- I have omitted the `apt-cache policy kubelet | head -n 20` step as the output is difficult to read in the Ansible log. You can ssh onto c1-cp1 and run it manually after the playbook has completed.
- kubectl is installed as part of kubeadm - and it seems to always include the latest minor version (e.g.1.29.1-1.6 when you asked for 1.1-1) so I have omitted the explicit install of kubectl - it does not affect the exercises at all.
- TODO: creation and distribution of node SSH keys and configuration of each node's /etc/hosts so you can get lost in an endless chain of ssh sessions :) (It may be convenient to ssh from control plane to worker nodes but you should be able to do everything from your workstation)

### cplane

This step corresponds to the `CreateControlPlaneNode-containerd.sh` step in 03/demos folder of the course exercise files. It runs on the c1-cp1 control plane only and does the following:
 - Installs the control plane via kubeadm
 - installs the Calico network overlay with the default pod CIDR of 172.16.0.0/16. You should not need to change this, but if you do, configure a pod_cidr var in the playbook to override the role default value. You should **not** edit the template or change the default value in the role's default folder.
 - Runs some  Quality of Life tasks that will add `kubectl` autocompletion and also alias kubectl to `k`.

 Note: It can be convenient to have kubectl on your workstation. If you already have it, just scp the config file from c1-cp1:/home/psite/.kube and merge it with any other configs you may have. If you need to install it, here's a quick way (see the [kubectl docs](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) for more details)

  - You likely don't want the latest version so edit the curl command in the docs to something like `curl -LO "https://dl.k8s.io/release/1.29.1/bin/linux/amd64/kubectl"` for amd64 on linux (replacing 1.29.1 with whatever version you like) and copy the kubectl binary  to /usr/bin and give it 755 permissions.
  - create a $HOME/.kube folder
  - copy the config with `scp psight@c1-cp1:/home/psight/.kube/config $HOME/.kube` and  protect it with `chmod 600 $HOME/.kube/config`
  - `kubectl version` will show you kubectl and cluster control plane versions. If you see those, you're good. 
  - Follow the instructions in the doc to configure autocompletion and aliasing.

 ### workers

 This is the final step, corresponding to the `CreateNodes-containerd.sh` step in 03/demos folder of the course exercise files.The steps in this script are identical to those in the first PackageInstallation step, so there is no need to repeat that in this playbook. ALl this playbook does is to join the node to the cluster.

## roadmap
 - Vagrant - create Ubuntu box with Ansible etc. and publish it. Add a vagrantfile to start VMs
 - CNI - possibly add an option to choose between Calico or Flannel. Calico is HUGE and overkill for a small HomeLab cluster. Later on, if you want to play with external ingress using something like [MetalLB]([https://metallb.universe.tf) and [Traefik]([https://doc.traefik.io/traefik/providers/kubernetes-ingress/), you will find that Calico does not work well. Flannel is much more lightweight and metalLB friendly.
- Write docs, including instructions for windows hosts (ugh!).
