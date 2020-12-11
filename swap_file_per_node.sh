sudo fallocate -l 128G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
cp /etc/fstab ~/
echo "/swapfile swap swap defaults 0 0" >> ~/fstab
sudo mv ~/fstab /etc/fstab
sudo chown root:root /etc/fstab
