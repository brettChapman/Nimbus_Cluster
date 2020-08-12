sudo apt-get install slurm-client

sudo mv ~/hosts /etc/
sudo mkdir -p /etc/slurm-llnl
sudo mkdir -p /var/spool/slurm-llnl
sudo mkdir -p /var/spool/slurmd
sudo mkdir -p /var/log/slurm-llnl

sudo -- sh -c "cat > /etc/slurm-llnl/cgroup.conf << 'EOF'
CgroupAutomount=yes
ConstrainCores=yes
ConstrainDevices=yes
ConstrainRAMSpace=yes"

sudo mv ~/slurm.conf /etc/slurm-llnl/slurm.conf
sudo chown slurm: /etc/slurm-llnl/slurm.conf
sudo chown slurm: /var/spool/slurm-llnl
sudo chown slurm: /var/spool/slurmd
sudo chown slurm: /var/log/slurm-llnl
sudo chown slurm: /etc/slurm-llnl/cgroup.conf
