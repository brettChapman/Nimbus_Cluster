pdcp -a compile_singularity_per_node.sh ~/

cd ~/singularity
sudo ./mconfig
sudo make -C ./builddir
sudo make -C ./builddir install
pdsh -a bash ./compile_singularity_per_node.sh
cd ~
sudo rm -dr ~/singularity
