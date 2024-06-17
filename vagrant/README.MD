I thought would be quick.... but Vagrant's stubbornness to use a NAT network interface breaks the APIserver's  advertised address - it defaults too the default route which on Vagrant VMs is the NAT interface. 

I've tried fixing the default route in the vagrant provisioner but something keeps putting it back.

A solution I will test maybe tomorrow is to have the vagrantfile set an advertised IP address environment variable for the bridged network and then have the kubeadm create task set the --apiserver-advertise-address parameter if that environment variable  is set. A bit ugly but I really don;t want to add IP variables to the playbooks.