# Script to help free space inbetween github CI jobs.
# Necessary because the images we build are large and github actions have space limit

sudo swapoff -a
sudo rm -f /swapfile
sudo apt clean