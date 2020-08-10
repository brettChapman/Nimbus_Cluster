pdsh -a sudo apt-get -yq install nfs-common
sudo apt-get install -yq rpcbind nfs-kernel-server

sudo -- sh -c "cat > /etc/exports << 'EOF'
/data 192.168.0.56(rw,sync,no_subtree_check)
/data 192.168.0.65(rw,sync,no_subtree_check)
/data 192.168.0.69(rw,sync,no_subtree_check)"

sudo /etc/init.d/rpcbind restart
sudo /etc/init.d/nfs-kernel-server restart
sudo exportfs -r

pdsh -a sudo mkdir /data
pdsh -a sudo chown -R ubuntu:ubuntu /data
pdsh -a sudo mount 192.168.0.57:/data /data

pdsh -a ls /data
sudo chown -R ubuntu:ubuntu /data
