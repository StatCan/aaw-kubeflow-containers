# Cleans caches and removes all docker images

sudo swapoff -a
sudo rm -f /swapfile
sudo apt clean

# Removes dangling images, NOT all unused images.  So this will not remove any prereqs we downloaded
# This is redundant if doing the docker rmi below
# docker image prune  

# Must do "|| true" because `docker rmi` exits with error code as the 'registry' 
# image is running and cannot be removed
docker rmi -f $(docker image ls -aq) || true
