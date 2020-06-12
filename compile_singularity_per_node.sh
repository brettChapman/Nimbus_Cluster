cd ~/singularity
sudo ./mconfig
sudo make -C ./builddir
sudo make -C ./builddir install
cd ~
sudo rm -dr ~/singularity
