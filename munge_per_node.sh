sudo systemctl stop munge
cd ~
sudo chown munge: munge.key
sudo mkdir -p /etc/munge/
sudo chown munge:munge /etc/munge/
sudo mv munge.key /etc/munge/munge.key
sudo chmod 400 /etc/munge/munge.key
sudo systemctl enable munge
sudo systemctl start munge
