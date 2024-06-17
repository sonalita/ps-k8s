# ps-k8s
Ansible playbooks to create the required infrastructure for the [Pluralsight Certified Kubernetes Administrator](https://www.pluralsight.com/paths/certified-kubernetes-administrator) path, including templates for creating nodes using either [Proxmox](https://www.proxmox.com/en/) or  with [Virtualbox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/) for VirtualBox provisioning. Both platforms are free but you will need a dedicated machine for proxmox as it is a full Linux distro.

I recommend that you fork this repo so you can customize and preserve your configuration for future use.

**WARNING: if you  have not yet done the course, I would recommend provisioning at least the control plane and one worker node manually before automating the building of the full cluster. You will learn more that way - but it is quite a tedious process that you have to repeat 5 times.**

There are separate README files in the `machines/proxmox` and `machines/vagrant` folders that contain more information on creating the VMs on those platforms.

These templates and playbooks will create the machines as required by the course. Once the playbook completes, you will have a fully provisioned cluster that you would normally create by working through the exercises in the `/03/demos` folder of the course's exercise files.

You will end up with:

| Node Name | ssh | Description |
| --- | --- | --- |
| c1-cp1 | `ssh psight@c1-cp1` | the control plane |
| c1-node1 | `ssh psight@c1-node1` | Worker node 1 |
| c1-node2 | `ssh psight@c1-node2` | Worker node 2 |
| c1-node3 | `ssh psight@c1-node3` | Worker node 3 |
| c1-storage |`ssh psight@c1-node3`| Used later in the course to work with Persistent Volumes and Stateful Sets. |

## Prerequisites
 - A virtualization platform. This repo includes a Proxmox template and a Vagrant Vagrantfile for Oracle Virtual Box. These are located in the `machines` folder.
 - A machine capable of running Ansible (Microsoft windows is problematic - either dual boot to a Linux Distro, use WSL  or create a workstation in VirtualBox - Linux Mint is a good Windows-like distro for building a workstation.)
 - If you are using **VirtualBox**, install [Vagrant](https://developer.hashicorp.com/vagrant/install?product_intent=vagrant) from Hashicorp then you can simply follow the instructions in the `machines/vagrant` folder to provision the necessary machines. **Note for virtualbox users - if you are using any other virtualization software, (e.g. docker) then you should disable that otherwise VirtualBox will not be able to use hardware virtualization and will run very slowly (if you start a machine in Virtualbox and see the infamous green turtle, your setup is broken - google "virtualbox green turtle" for help).**
 - If you have a **Proxmox** host, there is an ansible playbook to build a suitable template and a  `machines/proxmox/scripts/prox.sh` to create and manage your VMs. More details in the README in the `machines/proxmox` folder.
- If you are using a different virtual machine platform, you will need to build the boxes yourself. The recommendation is to use a Ubuntu base image. Each virtual machine should have the following specs:
    -  Minimum of 2 cpu cores, 
    - At least 8GB Ram (I have not tested with less but you may be able to reduce but the nodes may struggle with workloads)
    - 50GB disk (I think the course recommends 30 but you'll want some headroom for experimentation)
    - A static IP (either on the VM itself or via assigning fixed IPs for the MAC addresses in the DHCP settings on your router), If you have multiple network interfaces in your VMs, you will need to set the `k8s_api_ip` variable in the Ansible inventory file for the control plane node. The Vagrant inventory file does this.
    - A user `psight` with `sudo` access and preferably with NOPASSWD set (`sudo visudo` then add the line `psight ALL=(ALL) NOPASSWD: ALL`). If you do not wish to use `psight` as your user, please mentally adjust as you read these instructions - and you may need to modify some variables in the playbooks/templates.
- Add the IP addresses for the hostnames listed above to your hosts file (`/etc/hosts` on Linux or `c:\Windows\System32\Drivers\etc\hosts` on Windows). You will need to run your editor with elevated permissions ("sudo" or "run as admin") when editing your hosts file
- I recommend using VSCode on your workstation (and possibly on the control plane) as the labs on the course are presented using VSCode and it may be easier to follow along. The "remote SSH" extension will allow you to run vscode on any of the nodes. The nodes will also have nano, vi and vim available if you prefer not to use VSCode.
- From your workstation, confirm that you can run `ssh psight@c1-cp1` without requiring a password, and then once connected, can run `sudo echo hello` without being prompting for a password. This will simplify running the Ansible plays, and save you some typing during the course.
- Repeat the above tests for `c1-node1`, `c1-node2`, `c1-node3` and `c1-storage`.
- **ssh onto each node once before running the playbooks to ensure you have the fingerprint in your workstation's known_hosts file**
- **For Vagrant provisioning (or if you have custom VMS with multiple network interfaces), set the IP address of c1-cp1 in the variable k8s_api_ip in the `ansible/inventory/vagrant` file** No changes should be needed for the proxmox inventory file.

## Running the Ansible Playbooks

Firstly, check that Ansible can reach your nodes. If you have changed the user on the nodes, edit the `ansible/inventory/group-vars/all.yml` file to reflect the correct user.
from the `ansible` folder, run one of the following command based on your platform: 

```bash
ansible -i inventory/proxmox all -m ping
```

OR

```bash
ansible -i inventory/vagrant all -m ping
```
There are shortcut scripts in the repo for this in the `ansible` folder if you prefer less typing. `

If all is well, you will see green "pong" messages from each of the nodes and you can continue with the playbooks. If the script hangs, you didn't fingerprint the nodes and it is waiting for you to confirm acceptance. Type "yes&lt;ENTER&gt;>" as many times as needed to allow the playbook to complete. If you ever redeploy the nodes or edit any hardware details, you will have to remove the old fingerprints with `ssh-keygen -R <host-name>` and reconnect with ssh to accept the new fingerprint.

### variables you might want to change
 - in `ansible/inventory/group_vars/all.yaml`, Update the ansible_user if you are not using the psight user. Also check the Kubernetes major and minor versions.
 - if you chose to use different hostnames, update the relevant `ansible/inventory` file

 ### Provisioning

 All the playbooks to provision the cluster are fully idempotent. From the `ansible` folder, run `ansible-playbook  -i provisioning/<platform> site.yaml` replacing &lt;platform&gt; with proxmox or vagrant. Again, there are shortcut scripts in the repo for this in the `ansible` folder if you prefer less typing. `

 ## Playbook information

 ### base

This playbook corresponds to the "PackageInstallation-containerd.sh" script in the `/03/demos` folder of the course exercise files. It does the following:

 - Configures the kernel with the necessary network mods, and updates sysctl
 - Installs containerd and configures the cgroup settings correctly.
 - Installs the Kubernetes packages for the version set in `group_vars/all.yaml` **Note: Part of the course covers upgrading your control plane so you should not install the very latest version**

Note the following differences between the playbook and the exercise steps:

- Swap is already disabled in the proxmox template and the vagrant provisioning script.
- I have omitted the `apt-cache policy kubelet | head -n 20` step as the output is difficult to read in the Ansible log. You can ssh onto c1-cp1 and run it manually after the playbook has completed.
- kubectl is installed as part of kubeadm - and it seems to always include the latest minor version (e.g.kubectl 1.29.1-1.6 will be installed when you asked for kubeadm 1.1-1) so I have omitted the explicit install of kubectl: it does not affect the exercises at all.

### cplane

This step corresponds to the `CreateControlPlaneNode-containerd.sh` step in the `03/demos` folder of the course exercise files. It runs on the c1-cp1 control plane only and does the following:
 - Installs the control plane via kubeadm (and sets the api end point correctly if your VM has multiple network interfaces)
 - installs the Calico network overlay with the default pod CIDR of 172.16.0.0/16. You should not need to change this, but if you do, configure a `pod_cidr` var in the playbook to override the role default value. You should **not** edit the template or change the default value in the role's default folder.
 - Runs some  Quality of Life tasks that will add `kubectl` autocompletion and also alias kubectl to `k`.

 Note: It can be convenient to have kubectl on your workstation. If you already have kubectll installed you can just scp the config file from `c1-cp1:/home/psite/.kube` and merge it with any other configs you may have. If you need to install it, here's a quick way (see the [kubectl docs](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) for more details)

  - You likely don't want the latest version so edit the curl command in the docs to something like `curl -LO "https://dl.k8s.io/release/1.29.1/bin/linux/amd64/kubectl"` for amd64 on linux (replacing 1.29.1 with whatever version you like) and copy the kubectl binary  to /usr/bin and give it 755 permissions.
  - create a $HOME/.kube folder
  - copy the config with `scp psight@c1-cp1:/home/psight/.kube/config $HOME/.kube` and  protect it with `chmod 600 $HOME/.kube/config`
  - `kubectl version` will show you kubectl and cluster control plane versions. If you see those, you're good. 
  - Follow the instructions in the doc to configure autocompletion and aliasing.

 ### workers

 This is the final step, corresponding to the `CreateNodes-containerd.sh` step in the `03/demos` folder of the course exercise files.The steps in the exercise script are identical to those in the first `PackageInstallation` step, so there is no need to repeat that in this playbook. All this playbook does is to join the node to the cluster.
