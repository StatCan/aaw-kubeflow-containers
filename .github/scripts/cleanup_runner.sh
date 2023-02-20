

# ------------------------------- MACROS ------------------------------- # 
# macro to compute available space
# REF: https://unix.stackexchange.com/a/42049/60849
# REF: https://stackoverflow.com/a/450821/408734
getAvailableSpace() { echo $(df -a $1 | awk 'NR > 1 {avail+=$4} END {print avail}'); }
# macro to make Kb human readable (assume the input is Kb)
# REF: https://unix.stackexchange.com/a/44087/60849
formatByteCount() { echo $(numfmt --to=iec-i --suffix=B --padding=7 $1'000'); }
# macro to output saved space
printSavedSpace() {
    saved=${1}
    title=${2:-}
    echo ""
    printSeparationLine '*' 80
    if [ ! -z "${title}" ]; then
    echo "=> ${title}: Saved $(formatByteCount $saved)"
    else
    echo "=> Saved $(formatByteCount $saved)"
    fi
    printSeparationLine '*' 80
    echo ""
}

# macro to print output of dh with caption
printDH() {
    caption=${1:-}
    printSeparationLine '=' 80
    echo "${caption}"
    echo ""
    echo "$ dh -h /"
    echo ""
    df -h /
    echo "$ dh -a /"
    echo ""
    df -a /
    echo "$ dh -a"
    echo ""
    df -a
    printSeparationLine '=' 80
}


# Display initial disk space stats
AVAILABLE_INITIAL=$(getAvailableSpace)
AVAILABLE_ROOT_INITIAL=$(getAvailableSpace '/')
printDH "BEFORE CLEAN-UP:"
echo ""


############################## CLEAN UP ############################## 
# -------------------------- Remove Swap storage -------------------------- #
BEFORE=$(getAvailableSpace)

sudo swapoff -a
sudo rm -f /swapfile

AFTER=$(getAvailableSpace)
SAVED=$((AFTER-BEFORE))
printSavedSpace $SAVED "Swap storage"

# -------------------------- Remove Android library -------------------------- # 
BEFORE=$(getAvailableSpace)

sudo rm -rf /usr/local/lib/android
AFTER=$(getAvailableSpace)
SAVED=$((AFTER-BEFORE))
printSavedSpace $SAVED "Android library"

# -------------------------- Remove .NET runtime -------------------------- # 
BEFORE=$(getAvailableSpace)
sudo rm -rf /usr/share/dotnet               # https://github.community/t/bigger-github-hosted-runners-disk-space/17267/11

AFTER=$(getAvailableSpace)
SAVED=$((AFTER-BEFORE))
printSavedSpace $SAVED ".NET runtime"

# -------------------------- Remove Haskell runtime -------------------------- # 
BEFORE=$(getAvailableSpace)
sudo rm -rf /opt/ghc

AFTER=$(getAvailableSpace)
SAVED=$((AFTER-BEFORE))
printSavedSpace $SAVED "Haskell runtime"


# -------------------------- docker cleanup -------------------------- # 
# Removes dangling images, NOT all unused images.  So this will not remove any prereqs we downloaded
# This is redundant if doing the docker rmi below
# docker image prune  

# Must do "|| true" because `docker rmi` exits with error code as the 'registry' 
# image is running and cannot be removed
BEFORE=$(getAvailableSpace)

docker rmi -f $(docker image ls -aq) || true
AFTER=$(getAvailableSpace)
SAVED=$((AFTER-BEFORE))
printSavedSpace $SAVED "Docker images"

# -------------------------- clean apt -------------------------- #
sudo apt clean
