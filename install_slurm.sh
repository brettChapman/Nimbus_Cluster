sudo touch /run/slurmdbd.pid
sudo touch /run/slurmctld.pid
sudo chown slurm:slurm /run/slurmdbd.pid
sudo chown slurm:slurm /run/slurmctld.pid

sudo apt-get install slurmctld slurmdbd
sudo apt-get install mailutils -yq
pdsh -a sudo apt-get update
pdsh -a sudo apt-get -yq upgrade
pdsh -a sudo apt-get -yq install slurmd pdsh
pdcp -a slurm.conf ~/slurm.conf
pdcp -a setup_host_for_slurm.sh ~/setup_host_for_slurm.sh
pdsh -a bash ./setup_host_for_slurm.sh
sudo mkdir -p /etc/slurm-llnl
sudo mv ~/slurm.conf /etc/slurm-llnl/slurm.conf
sudo chown slurm:slurm /etc/slurm-llnl/slurm.conf
sudo mkdir -p /var/spool/slurm-llnl
sudo chown slurm:slurm /var/spool/slurm-llnl
sudo mkdir -p /var/spool/slurmd
sudo chown slurm:slurm /var/spool/slurmd
sudo chown slurm:slurm /var/log/
sudo mkdir -p /var/log/slurm-llnl
sudo touch /var/log/slurm-llnl/slurmctld.log
sudo touch /var/log/slurm-llnl/slurmd.log
sudo touch /var/log/slurm-llnl/slurmdbd.log
sudo chown slurm:slurm /var/log/slurm-llnl
sudo chown slurm:slurm /var/log/slurm-llnl/slurmctld.log
sudo chown slurm:slurm /var/log/slurm-llnl/slurmd.log
sudo chown slurm:slurm /var/log/slurm-llnl/slurmdbd.log

sudo -- sh -c "cat > /etc/slurm-llnl/cgroup.conf << 'EOF'
CgroupAutomount=yes
ConstrainCores=yes
ConstrainDevices=yes
ConstrainRAMSpace=yes"

sudo chown slurm:slurm /etc/slurm-llnl/cgroup.conf
