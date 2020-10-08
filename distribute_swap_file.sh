sudo fallocate -l 35G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
cp /etc/fstab ~/
echo "/swapfile swap swap defaults 0 0" >> ~/fstab
sudo mv ~/fstab /etc/fstab
sudo chown root:root /etc/fstab

pdcp -a swap_file_per_node.sh ~/

pdsh -a bash ./swap_file_per_node.sh
