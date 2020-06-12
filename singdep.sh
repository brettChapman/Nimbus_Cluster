pdcp -a singdep_per_node.sh ~/

sudo apt-get update && sudo apt-get install -y \
    		build-essential \
    		libssl-dev \
    		uuid-dev \
    		libgpgme11-dev \
    		squashfs-tools \
    		libseccomp-dev \
    		wget \
    		pkg-config \
    		git

pdsh -a bash ./singdep_per_node.sh
