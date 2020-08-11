dd if=/dev/urandom of=~/munge.key bs=1c count=4M
pdcp -a munge.key ~/munge.key
pdcp -a munge_per_node.sh ~/munge_per_node.sh
pdsh -a bash ./munge_per_node.sh
sudo systemctl stop munge
sudo chown munge: munge.key
sudo mkdir -p /etc/munge/
sudo chown munge:munge /etc/munge/
sudo mv munge.key /etc/munge/munge.key
sudo chmod 400 /etc/munge/munge.key
sudo systemctl enable munge
sudo systemctl start munge
