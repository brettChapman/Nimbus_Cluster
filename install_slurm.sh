sudo apt-get install slurmctld slurmdbd
pdsh -a sudo apt-get update
pdsh -a sudo apt-get -yq upgrade
pdsh -a sudo apt-get -yq install slurmd pdsh
pdcp -a slurm.conf ~/slurm.conf
pdcp -a setup_host_for_slurm.sh ~/setup_host_for_slurm.sh
pdsh -a bash ./setup_host_for_slurm.sh
sudo mkdir -p /etc/slurm-llnl
sudo mv ~/slurm.conf /etc/slurm-llnl/slurm.conf
sudo chown slurm: /etc/slurm-llnl/slurm.conf
sudo mkdir -p /var/spool/slurm-llnl
sudo chown slurm: /var/spool/slurm-llnl
sudo mkdir -p /var/spool/slurmd
sudo chown slurm: /var/spool/slurmd
sudo mkdir -p /var/log/slurm-llnl
sudo chown slurm:syslog /var/log
sudo chown slurm: /var/log/slurm-llnl

sudo -- sh -c "cat > /etc/slurm-llnl/cgroup.conf << 'EOF'
CgroupAutomount=yes
ConstrainCores=yes
ConstrainDevices=yes
ConstrainRAMSpace=yes"

sudo chown slurm: /etc/slurm-llnl/cgroup.conf
