pdcp -a ~/singularity_per_node.sh ~/
cd ~
sudo git clone https://github.com/hpcng/singularity.git
cd singularity
sudo git checkout v3.7.0
cd ~

pdsh -a bash ./singularity_per_node.sh
