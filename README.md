# README.md - `Nimbus Cluster`

This repository contains instructions and scripts for setting up a Nimbus Cluster using Slurm ([https://nimbus.pawsey.org.au/](https://nimbus.pawsey.org.au/)).

Additional useful documentation:

[Timo Lassmann's Nimbus Cluster Instructions](https://github.com/TimoLassmann/dot-files/blob/master/additional/setup_nimbus_cluster.org)

[Slurm Webinar](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=2ahUKEwic07CrssbpAhWl4HMBHQylDnIQFjAAegQIBRAB&url=ftp%3A%2F%2Fmicroway.com%2Fpub%2Ffor-customer%2FSDSU-Training%2FWebinar_2_Slurm_II--Ubuntu16.04_and_18.04.pdf&usg=AOvVaw3TaEKxv9Iqe5qDUCp1GjQX)

[Slurm Resource Management](https://www.admin-magazine.com/HPC/Articles/Resource-Management-with-Slurm)

[Slurm Wiki](https://wiki.fysik.dtu.dk/niflheim/SLURM)

[Slurm database installation Wiki](https://wiki.fysik.dtu.dk/niflheim/Slurm_database)

Disclaimer: This is my first time setting up a cluster with Slurm. If you have more experience and wouldn't mind making any suggestions or pointing out something I missed, please let me know. I'm contactable on brett.chapman78@gmail.com or brett.chapman@murdoch.edu.au. Thank you.

## Setting up the cluster

### Initial setup

Prepare clusters according to: [Pawsey Managing Instances](https://support.pawsey.org.au/documentation/display/US/Manage+an+Instance+Cluster).

Create a cluster called “node”, which can create multiple nodes at once and name them as node-1, -2 etc after you select how many instances you want. Then create one additional node as node-0 as the master node.

On your desktop set up ssh-agent and use ForwardAgent for forwarding on SSH credentials and ensure your Nimbus SSH credentials are set up for ssh-agent in your bash_profile or bashrc script as well. Added like so: ssh-add ~/.ssh/Nimbus.pem

After logging into node-0 ensure that all nodes are listed in hosts with their associated 192.168.xx.xx IPs:

Example:
```
cat /etc/hosts
127.0.0.1 localhost
192.168.0.109 node-0
192.168.0.112 node-1
192.168.0.143 node-2
192.168.0.63 node-3

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
```
	
#### 1.	Install pdsh as described here:
[Pawsey Managing Instances](https://support.pawsey.org.au/documentation/display/US/Manage+an+Instance+Cluster).

Note: You may need to update and upgrade first if pdsh isn’t in the package list with.
```
sudo apt-get update -y
sudo apt-get -yq upgrade
sudo apt-get install pdsh -y
```
#### 2.	Install pdsh across all nodes:
```
pdsh -a sudo apt-get update -y
pdsh -a sudo apt-get -yq upgrade
pdsh -a sudo apt-get install pdsh -y
```
#### 3.	Ensure all the nodes are updated and upgraded if not already done:
```
sudo apt-get update -y
sudo apt-get -yq upgrade
pdsh -a sudo apt-get update
pdsh -a sudo apt-get -yq upgrade
```
### MUNGE setup

#### 1.	Install dependencies and MUNGE:
```
sudo apt-get -yq install libmunge-dev libmunge2 munge
pdsh -a sudo apt-get -yq install libmunge-dev libmunge2 munge
```
#### 2.	Sync munge key across all nodes:

Copy scripts ```munge_per_node.sh``` and ```distribute_munge.sh``` to your home directory.

Run:
```
bash ./distribute_munge.sh
```
#### 3.	Check Munge is installed and running on all nodes:
```
systemctl status munge
pdsh -a systemctl status munge
```
### SLURM setup

Generate a Slurm config file using the [Slurm Configurator](https://slurm.schedmd.com/configurator.html). Ensure that the Slurm version you’re going to use will be the same as the public configurator (check with “sudo apt search slurm”). Otherwise install on your master node and download the following:

#### 1.	Install configurator on your master node:
```
sudo apt install slurm-wlm-doc
```
Download documents from master node:
```
scp ubuntu@X:/usr/share/doc/slurm-wlm-doc/html/configurator.html ./

(where X=master node IP where the documents are)
```
Note: Depending on the Slurm version, the configurator may be in /usr/share/doc/slurm-wlm/html/.

Open the configurator in your browser.

#### 2.	Generating a config file:

It is critical to correctly name the master node and the worker nodes. These names have to match exactly what is shown in the Nimbus OpenStack dashboard.

Make sure the number of CPUs, main memory etc are set correctly for each worker node. If you are unsure of what these values are install the slurm daemon on a node to check: 

ssh into one of the worker nodes (e.g. ssh node-1) and then:
```
sudo apt-get install -yq slurmd
```
and then run:
```
slurmd -C
```

##### Set up the following in the config file:

- Set ControlMachine to node-0 (if the master node is named as such)
- Set NodeName to node-[1-3] (if named and numbered as such)
- Set SlurmUser to slurm
- Set StateSaveLocation to /var/spool/slurm-llnl
- Set ProctrackType to Cgroup
- Set TaskPlugin to Cgroup
- Set AccountingStorageType to FileTxt
- Set JobAcctGatherType to None
- Set SlurmctldLogFile to /var/log/slurm-llnl/slurmctld.log
- Set SlurmdLogFile to /var/log/slurm-llnl/slurmd.log
- Set SlurmctldPidFile to /var/run/slurmctld.pid
- Set SlurmdPidFile to /var/run/slurmd.pid

##### The below settings are for configuring SlurmDBD and are optional (they can be left out if SlurmDBD is not needed or for debugging purposes, and added in later)

- Set JobCompType to MySQL (set to none if leaving out SlurmDBD)
- Set JobCompLoc to slurm_acct_db
- Set JobCompHost to localhost
- Set JobCompUser to slurm
- Set JobCompPass to password (or whatever password was chosen for MariaDB)
- All other settings can be left as default.

Finally copy the output of the configurator webpage into a file called slurm.conf and send a copy to the home directory of your master node (simply copying and pasting into the file works best to preserve formatting). 

#### 3. Copy hosts to all nodes
```
pdcp -a /etc/hosts ~/
pdsh -a sudo mv ~/hosts /etc/hosts
```
#### 4.	Copy and run the following scripts:

Copy scripts ```setup_host_for_slurm.sh``` and ```install_slurm.sh``` to your home directory.

The ```install_slurm.sh``` script configures the master node, copies the ```setup_host_for_slurm.sh``` script to all nodes and configures them. It is expected that the ```slurm.conf``` file is in the home directory of user ubuntu.

Run:
```
bash ./install_slurm.sh
```
### MariaDB and MySQL setup

#### 1.	Enable SlurmDBD:
```
sudo systemctl enable slurmdbd
```
#### 2.	Install, start and enable MariaDB:
```
sudo apt-get install mariadb-server -yq
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo systemctl status mariadb
```
#### 3.	Configure the MariaDB root password:
```
sudo /usr/bin/mysql_secure_installation
```
Set password as “password” (as selected in the slurm.conf flle) and select Y for remaining questions.

#### 4.	Grant permissions and create database in MariaDB:
```
sudo mysql -p (enter chosen password)
```

```
MariaDB> grant all on slurm_acct_db.* TO 'slurm'@'localhost' identified by 'password' with grant option;
MariaDB> SHOW VARIABLES LIKE 'have_innodb';
MariaDB> create database slurm_acct_db;
```
Check that all grants to slurm user have been accepted:
```
MariaDB> show grants;
MariaDB> quit;
```
#### 5.	Edit MariaDB config files:
```
sudo vim /etc/mysql/my.cnf
```
Append the following to the file:

```
[mysqld]
innodb_buffer_pool_size=16G
innodb_log_file_size=64M
innodb_lock_wait_timeout=900
```

Note: it is recommended to set the innodb_buffer_pool_size to half the RAM on the slurmdbd server. In this case it is 16GB (half of 32G).

#### 6.	Implement the changes:
```
sudo systemctl stop mariadb
sudo mv /var/lib/mysql/ib_logfile? /tmp/
sudo systemctl start mariadb
```
#### 7.	Check that the changes took affect:
```
sudo mysql -p (enter chosen password)
```

```
MariaDB> SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
```
### SLURMDBD setup

#### 1.	Create SlurmDBD config file:
```
zcat /usr/share/doc/slurmdbd/examples/slurmdbd.conf.simple.gz > slurmdbd.conf
```
Edit the slurmdbd.conf file (sudo vim slurmdbd.conf) set the following:

- Set DbdHost to localhost
- Set StorageHost to localhost
- Set StorageLoc to slurm_acct_db
- Set StoragePass to password (or whatever password was chosen to access MariaDB)
- Set StorageType to accounting_storage/mysql
- Set StorageUser to slurm
- Set LogFile to /var/log/slurm-llnl/slurmdbd.log
- Set PidFile to /var/run/slurmdbd.pid
- Set SlurmUser to slurm

#### 2.	Move the slurmdbd.conf to the slurm directory:
```
sudo mv slurmdbd.conf /etc/slurm-llnl/
```
#### 3.	Set permissions and ownership:
```
sudo chown slurm:slurm /etc/slurm-llnl/slurmdbd.conf
sudo chmod 664 /etc/slurm-llnl/slurmdbd.conf
```
#### 4.	Run SlurmDBD interactively with debug options to check for any errors (this will also test if the MariaDB “slurm_acct_db” database can be populated):
```
sudo slurmdbd -D -vvv
```
End with ctrl-C

#### 5.	Check that the “slurm_acct_db” has been populated with tables:
```
mysql -p -u slurm slurm_acct_db
```

```
MariaDB> show tables;
MariaDB> quit;
```
#### 6.	Start the SlurmDBD service:
```
sudo systemctl enable slurmdbd
sudo systemctl start slurmdbd
sudo systemctl status slurmdbd
```
### FINAL error checks

#### 1.	Check for any errors with SlurmDBD, SlurmCTLD and SlurmD:

Check SlurmDBD for errors:
```
sudo slurmdbd -D -vvv
```
Check SlurmCTLD for errors:
```
sudo slurmctld -Dcvvv
```
Check SlurmD for errors (start-up services first):
```
sudo systemctl enable slurmdbd
sudo systemctl start slurmdbd
sudo systemctl status slurmdbd

sudo systemctl stop slurmctld
sudo systemctl start slurmctld
sudo systemctl status slurmctld

pdsh -a sudo systemctl stop slurmd
pdsh -a sudo systemctl enable slurmd
pdsh -a sudo systemctl status slurmd

pdsh -a sudo slurmd

pdsh -a sudo slurmd -Dcvvv
```

Errors can also be viewed in the log files:

```
sudo cat /var/log/slurm-llnl/slurmctld.log | less -S
sudo cat /var/log/slurm-llnl/slurmdbd.log | less -S
pdsh -a sudo cat /var/log/slurm-llnl/slurmd.log | less -S
```
	
### FINAL Start SLURMDB, SLURMCTLD and SLURMD services

```
sudo systemctl enable slurmdbd
sudo systemctl start slurmdbd

sudo systemctl stop slurmctld
sudo systemctl start slurmctld

pdsh -a sudo systemctl stop slurmd
pdsh -a sudo systemctl enable slurmd

pdsh -a sudo slurmd
```
Note: You should now be able to run the following commands with no problems:
```
sinfo (displays node information)
sudo sacct (requires SlurmDBD and shows previous or running jobs)
scontrol show jobs (shows details of currently running jobs)
scontrol ping (pings slurmctld and shows its status)
```

If after setting up all services, some services appear to be inactive (dead)/failed after running the ```status``` commands, try running the following commands to restart them (I found this to be the case for slurmd with my 2nd slurm cluster setup):
```
sudo service slurmdbd restart
sudo service slurmctld restart
pdsh -a sudo service slurmd restart
sudo systemctl status slurmdbd
sudo systemctl status slurmctld
pdsh -a sudo systemctl status slurmd
```

### **Note 1: I successfully ran Slurm with Ubuntu 20.04 LTS and Slurm version 19.05.5 (for some reason the Slurm controller appears to only fail when using the Pawsey custom built Ubuntu images).**
### **Note 2: Ubuntu 20.04 LTS images can be obtained from http://cloud-images.ubuntu.com/ and uploaded as RAW format, through the Nimbus OpenStack dashboard, under "Compute" -> "Images" -> "Create Image", as LTS images are no longer available through Nimbus.**

### Setup NFS data volume

#### 1. It is advised to first mount a large volume to your master node, outlined here: [Attaching a storage volume](https://support.pawsey.org.au/documentation/display/US/Attach+a+Storage+Volume). An example of a 20 node cluster with 1 master node, first create instances with 3TB each root volume, and add an additional large separate volume be mounted to the master node. If resizing the volume before reattaching, follow the steps in the link provided, and if unmounting the drive first becomes an issue with drive busy warnings, then follow the steps in the trouble shooting section.

#### 2.	Look in /etc/hosts on the master node (node-0 in this case):
```
grep 192.168 /etc/hosts
192.168.0.109 node-0
192.168.0.112 node-1
192.168.0.143 node-2
192.168.0.63 node-3
```
#### 3.	Replace your IP addresses in the ```setup_NFS.sh``` script. The final mounted disk is on the master node (in this case node-0 with IP 146.118.70.57).

Note: If mounting the folders goes wrong and you end up with stale file handles, just soft reboot the instances and then you can remove the folders.

Run:
```
bash ./setup_NFS.sh
```

### Setup swap files across nodes

If you intend to run memory intensive tasks, it's advisable to setup a swap file. I've followed instructions from [Linuxize: How to add swap space on Ubuntu 20.04](https://linuxize.com/post/how-to-add-swap-space-on-ubuntu-20-04)

Copy scripts ```distribute_swap_file.sh``` and ```swap_file_per_node.sh``` to your home directory.

Replace the swap file size for the master node and worker nodes in the ```distribute_swap_file.sh``` and ```swap_file_per_node.sh``` scripts if needed (I had 35GB set for the master node and 2000GB set for the worker nodes -- this is highly dependent on the work loads expected).

Run:
```
bash ./distribute_swap_file.sh
```

### Setup local password

It's important to set up a local password on each node, so that if all else fails you can log into the instance through the Nimbus OpenStack dashboard on each instance.

Put the following into a bash script (script.sh) and edit the "password" to whatever you choose:
```
yes password | sudo passwd ubuntu
```

Place the bash script into your home directory "~/", copy across to all nodes ```pdcp -a script.sh ~/``` and then run ```pdsh -a bash ./script.sh```

This will ensure you can always log into your instance from the console, if access from SSH is blocked or the instance becomes unresponsive.

### Installing essential applications

#### 1.	Installation of Docker
	
```
sudo apt-get install docker.io -y
pdsh -a sudo apt-get install docker.io -y

sudo systemctl enable --now docker 
pdsh -a sudo systemctl enable --now docker

sudo usermod -aG docker ubuntu
pdsh -a sudo usermod -aG docker ubuntu
```

Then soft-reboot all the nodes

#### 2.	Installation of GO

```
sudo apt-get install golang -y
pdsh -a sudo apt-get install golang -y
```
The GO version needed is >1.13. If the system you're installing on only apt-get installs versions <1.13, then try the following:

First uninstall the incorrect version of GO:
```
sudo apt-get remove golang-go
sudo apt-get remove --auto-remove golang-go

pdsh -a sudo apt-get remove golang-go
pdsh -a sudo apt-get remove --auto-remove golang-go
```

Second, remove the GO folder:
```
sudo rm -dr /usr/local/go
pdsh -a sudo rm -dr /usr/local/go
```

Third, run the following:
```
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:longsleep/golang-backports
sudo apt-get update -y
sudo apt-get -yq upgrade
sudo apt-get install golang-go -y

pdsh -a sudo apt-get install software-properties-common
pdsh -a sudo add-apt-repository ppa:longsleep/golang-backports
pdsh -a sudo apt-get update -y
pdsh -a sudo apt-get -yq upgrade
pdsh -a sudo apt-get install golang-go -y
```

#### 3.	Installation of Singularity

Install dependencies on all nodes:

Copy scripts ```singdep_per_node.sh``` and ```singdep.sh``` to your home directory.	

Run:
```
bash ./singdep.sh
```

Checking out Singularity from GitHub on all nodes:

Note: If updating to a different version of Singularity, first delete all executables with:
```
sudo rm -rf /usr/local/libexec/singularity
pdsh -a sudo rm -rf /usr/local/libexec/singularity
```
Decide on a release version from: [https://github.com/hpcng/singularity/releases](https://github.com/hpcng/singularity/releases)
In this case we chose version 3.5.3

Copy scripts ```singularity_per_node.sh``` and ```install_singularity.sh``` to your home directory and edit them as necessary with your choice of Singularity version

Run:
```
bash ./install_singularity.sh
```

#### 4.	Compile Singularity:

Copy scripts ```compile_singularity_per_node.sh``` and ```compile_singularity.sh``` to your home directory

Run:
```
bash ./compile_singularity.sh
```

### Submitting jobs with SLURM

Sbatch example (submit.sh):

```
#!/bin/bash
#SBATCH --nodes=3
# allow use of all the memory on the node
#SBATCH --ntasks-per-node=8
#SBATCH --mem=0
# request all CPU cores on the node
#SBATCH --exclusive
# Customize --partition as appropriate
#SBATCH --partition=debug

srun -n 24 ./my_program.py
```
Running the job:
```
sbatch submit.sh
```

In this example we are running the job across 3 nodes, each with 8 cores, totalling 24 processors.

### Adding additional nodes to your cluster

When expanding the size of your cluster you will need to revisit step 1 onwards, setup your mounted shared drive /data with a now modified ```setup_NFS.sh``` script with the additional nodes IP, install munge, slurm and all the other dependent software.

You will also need to update your ```/etc/genders```, ```/etc/hosts``` and your ```/etc/slurm-llnl/slurm.conf``` files. It is easier just to re-run most of the scripts from the start with subtle changes to the ```/etc/hosts``` and ```slurm.conf``` files, as these will need to be redistributed across the nodes, as well as the munge key.

Updating the ```slurm.conf``` file can simply be the addition of an identical node with the exact same hardware (simply change ```node-[1-3]``` to ```node-[1-4]``` etc.

Alternatively, the additional node can have different hardware configurations (extra CPUs and/or RAM). A new partition would need to be added. This can be done by adding new lines to your ```slurm.conf``` file in a similar way to the following: 

```
NodeName=node-[1-3] CPUs=8 RealMemory=32116 Sockets=1 CoresPerSocket=4 ThreadsPerCore=2 State=UNKNOWN
NodeName=node-[4] CPUs=16 RealMemory=64323 Sockets=1 CoresPerSocket=8 ThreadsPerCore=2 State=UNKNOWN

PartitionName=debug Nodes=node-[1-3] Default=YES MaxTime=INFINITE State=UP
PartitionName=batch Nodes=node-[4] MaxTime=INFINITE State=UP
```

If previously configured nodes have changed IPs (for example if you delete the node-1 instance and replace node-1 with a new instance and IP) then you will need to first update the known hosts. Use the following command (amend to the number of worker nodes):

```
for i in {1..4}; do ssh-keygen -R node-$i; done
```

Since slurm is already up and running, all the services will need to be restarted for the changes to take affect. Simply follow the troubleshooting steps in the next section for restarting all the nodes and services.

When submitting jobs on the new nodes with a different partition, in this case ```batch``` on nodes with 16 cores, the following will need to be modified in all submission scripts:
```
#SBATCH --ntasks-per-node=16

#SBATCH --partition=batch
```

### Troubleshooting


- If at any time job output stops appearing in the /data directory, it may be that the shared /data folders are no longer mounted. Therefore, rerun the ```setup_NFS.sh``` script again.

- If after a cluster configuration change (altering ```slurm.conf```), reboot or power outage, your worker nodes may remain down and slurmd inactive, which can be seen by running ```sinfo``` and ```pdsh -a sudo systemctl status slurmd```. Try resetting and restarting all nodes and services, simply by running the following commands (amend to the number of worker nodes):

```
for i in {1..3}; do sudo scontrol update NodeName=node-$i state=idle; done

sudo service slurmctld restart
sudo service slurmdbd restart
pdsh -a sudo service slurmd restart
```

- If for whatever reason Munge or other Slurm services go inactive, and no other methods seem to work, try rerunning all the scripts, and then if all else fails, try hard-rebooting all nodes and then re-initialising all the nodes and services.

- If the /data drive becomes unmounted, simply run ```sudo mount /dev/vdc /data```

- If slurmd becomes unresponsive and the process becomes stuck (you see ```Unable to bind listen port (*:6818): Address already in use``` when running ```sudo slurmd -Dvvv```), then kill the slurmd processes on all nodes by running the following:

```
pdsh -a sudo killall -9 slurmd
```

- If for whatever reason, you want to start from the beginning again you can either destroy the instances and start again or uninstall slurm, munge and slurmdbd by running the following:

```
sudo apt-get remove --auto-remove slurmctld -y
sudo apt-get remove --auto-remove slurmdbd -y
sudo apt-get remove --auto-remove munge -y

pdsh -a sudo apt-get remove --auto-remove slurmd -y
pdsh -a sudo apt-get remove --auto-remove munge -y
```

- If you're trying to unmount a drive to resize the drive before reattaching and the drive appears busy, use the ```fuser -m``` command. For example:

```
ubuntu@node-0:/data/$ fuser -m /data
/data:               31346c

ubuntu@node-0:/data/$ ps -f 31346
UID        PID  PPID  C STIME TTY      STAT   TIME CMD
ubuntu   31346 31345  0 08:56 pts/0    Ss     0:00 -bash
```

- Use the ```man fuser``` command for more information.

- Use the ```kill``` command on any running process and edit any auto-mounts in ```/etc/fstab```, and then shut down the instance before attempting to detach the volume in the Nimbus dashboard. 


### Tips and tricks

Make full use of the ```sbatch``` command, such as using the begin and dependency parameters to schedule and string together a workflow.

Example using the begin parameter:
```
sbatch --begin=now submit_1.sh
sbatch --begin=now+12hours submit_2.sh
```

Example using the dependency parameter:
```
sbatch submit_1.sh
Submitted batch job 200
sbatch --dependency=afterok:200 submit_2.sh
```
Example using the dependency parameter with multiple jobs in a bash script:
```
#!/bin/bash

# first job with no dependencies
job1=$(sbatch submit_1.sh | cut -d ' ' -f 4)

# second job depends on the first completing with an exit code of zero (no errors)
job2=$(sbatch --dependency=afterok:$job1 submit_2.sh | cut -d ' ' -f 4)

# multiple jobs can depend on the second job completing
job3=$(sbatch --dependency=afterok:$job2 submit_3.sh | cut -d ' ' -f 4)
job4=$(sbatch --dependency=afterok:$job2 submit_4.sh | cut -d ' ' -f 4)

# the final job can depend on multiple jobs completing
job5=$(sbatch  --dependency=afterok:$job3:$job4 submit_5.sh | cut -d ' ' -f 4)
```

See the [sbatch](https://slurm.schedmd.com/sbatch.html) user page for more information and don't be afraid to look around online for other ideas to become familiar with the usage of different slurm commands.