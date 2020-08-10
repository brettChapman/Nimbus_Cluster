sudo apt-get install slurm-client

sudo mv ~/hosts /etc/
sudo mkdir -p /etc/slurm-llnl
sudo mkdir -p /var/spool/slurm-llnl
sudo mkdir -p /var/spool/slurmd
sudo mkdir -p /var/log/slurm-llnl
sudo touch /var/log/slurm-llnl/slurmctld.log
sudo touch /var/log/slurm-llnl/slurmd.log
sudo touch /var/log/slurm-llnl/slurmdbd.log

sudo -- sh -c "cat > /etc/slurm-llnl/cgroup.conf << 'EOF'
CgroupAutomount=yes
ConstrainCores=yes
ConstrainDevices=yes
ConstrainRAMSpace=yes"

sudo mv ~/slurm.conf /etc/slurm-llnl/slurm.conf
sudo chown slurm:slurm /etc/slurm-llnl/slurm.conf
sudo chown slurm:slurm /var/spool/slurm-llnl
sudo chown slurm:slurm /var/spool/slurmd
sudo chown slurm:slurm /var/log/
sudo chown slurm:slurm /var/log/slurm-llnl
sudo chown slurm:slurm /var/log/slurm-llnl/slurmctld.log
sudo chown slurm:slurm /var/log/slurm-llnl/slurmd.log
sudo chown slurm:slurm /var/log/slurm-llnl/slurmdbd.log
sudo chown slurm:slurm /etc/slurm-llnl/cgroup.conf
