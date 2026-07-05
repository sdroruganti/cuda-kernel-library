set -e

sudo apt-get update
sudo apt-get install -y build-essential dkms "linux-headers-$(uname -r)"

sudo apt-get remove --purge -y cuda-drivers nvidia-driver nvidia-dkms || true
sudo apt-get autoremove --purge -y
sudo dpkg --configure -a || true
sudo apt-get -f install -y || true

apt-cache policy nvidia-driver-580-open nvidia-driver-580 cuda-drivers-580

sudo apt-get install -y nvidia-driver-580-open

