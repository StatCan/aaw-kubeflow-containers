#!/bin/sh

# Requires
#
#     curl, jq


#######################################
###      Basic file/url tests       ###
#######################################

test_sha256 () {
	# This is the sha256 of the empty string
	if test "$1" = e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855; then
		echo "The curl command failed; file not found" >&2
		echo "Exiting."
		exit 1
	fi
}


test_url () {
	# At the moment, just ensure https. Could be extended.
	if ! echo "$1" | grep -q '^https://[^;]*$'; then
		echo 'URL failed. Have to use https!!!' >&2
		exit 1
	fi
}


#######################################
###          Download tests         ###
#######################################

check_mc () {
	NAME=mc
	printf "checksums.sh: checking %s" "$NAME" >&2

	# TO CONFIRM:
	#
	# Check curl https://dl.min.io/client/mc/release/linux-amd64/
	#
	# And see if we got the newest version.

	# THE TRAILING SLASH BELONGS HERE
	BASE_URL='https://dl.min.io/client/mc/release/linux-amd64/archive/'

	test_url "$BASE_URL" || exit 1

	VERSION=$(curl -sL "$BASE_URL" |
						 grep 'href="./mc.RELEASE.*.sha256sum"' |
						 sed 's~.*href="./\(mc.RELEASE.[0-9A-Z-]*\).sha256sum".*~\1~' |
						 sort -nr |
						 sed 1q)

	SHA_URL="$BASE_URL/$VERSION.sha256sum"

	# If we can curl
	curl -s "$SHA_URL" | awk \
			-v APP=mc \
			-v VERSION="$VERSION" \
			-v URL="$BASE_URL" \
			'NR==1 {printf "%s	%s	%s%s	%s\n", APP, VERSION, URL, $2, $1}'

	printf ' done.\n' >&2
}



check_kubectl () {
	NAME=kubectl
	printf "checksums.sh: checking %s" "$NAME" >&2

	VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
	URL="https://storage.googleapis.com/kubernetes-release/release/$VERSION/bin/linux/amd64/kubectl"

	SHA256=$(curl -fsL "$URL" | sha256sum | awk '{print $1}')

	test_sha256 "$SHA256" || exit 1

	printf "%s	%s	%s	%s\n" \
		   "$NAME" \
		   "$VERSION" \
		   "$URL" \
		   "$SHA256"

	printf ' done.\n' >&2
}





check_az () {
	# This is a deb install in disguise. We'll verify that the installer script is bona fide, tho
	# The installer script is versionless, and should not change?
	NAME=azcli
	printf "checksums.sh: checking %s" "$NAME" >&2

	VERSION=null
	URL=https://aka.ms/InstallAzureCLIDeb
	STATIC_SHA=c03302f47be07d02afe3edec63080c7806980c51709c016af2f27901d51417b4
	SHA256=$(curl -sL "$URL" | sha256sum | awk '{print $1}')
	[ "$SHA256" = "$STATIC_SHA" ] || {
		echo "chack_az: This is not the sha256sum I expected to see... Please investigate." >&2
	}

	printf "%s	%s	%s	%s\n" \
		   "$NAME" \
		   "$VERSION" \
		   "$URL" \
		   "$SHA256"

	printf ' done.\n' >&2
}



check_rstudio () {
	NAME=rstudio
	printf "checksums.sh: checking %s" "$NAME" >&2

	VERSION=$(curl --silent -L --fail https://download2.rstudio.org/ |
		tr -d '\n' |
		grep -o '<Key>rstudio-server-\([0-9.]*\)-amd64.deb</Key>' |
		sed 's~^<Key>rstudio-server-\([0-9.]*\)-amd64.deb</Key>~\1~g' |
		sort -nr |
		sed 1q)

	URL="https://download2.rstudio.org/rstudio-server-${VERSION}-amd64.deb"

	SHA256=$(curl -sL "$URL" | sha256sum | awk '{print $1}')

	printf "%s	%s	%s	%s\n" \
		   "$NAME" \
		   "$VERSION" \
		   "$URL" \
		   "$SHA256"

	printf ' done.\n' >&2
}



check_oh_my_zsh () {
    NAME=oh-my-zsh
    VERSION=$(curl --silent 'https://api.github.com/repos/deluan/zsh-in-docker/releases' | jq -r '.[0].tag_name')
    URL="https://github.com/deluan/zsh-in-docker/releases/download/${VERSION}/zsh-in-docker.sh"
	SHA256=$(curl -sL "$URL" | sha256sum | awk '{print $1}')
	printf "%s	%s	%s	%s\n" \
		   "$NAME" \
		   "$VERSION" \
		   "$URL" \
		   "$SHA256"

	printf ' done.\n' >&2
}



get_checksums () {
	cat <<EOF | column -t | tee "CHECKSUMS$([ -f CHECKSUMS ] && printf '.new' )"
#Application	Version	URL	SHA256
$(check_az)
$(check_kubectl)
$(check_mc)
$(check_rstudio)
$(check_oh_my_zsh)
EOF

	if [ -f CHECKSUMS.new ] && ! diff -qb CHECKSUMS CHECKSUMS.new > /dev/null 2>&1; then
		cat <<EOF

    CHECKSUMS differs from old version!
    ===================================

$(diff -b CHECKSUMS CHECKSUMS.new)


    NOTE: Newer != Better
    =====================

Some programs like kubectl *should not* be on the newest version, but
pinned to the version of the cluster. Take that into account before
modifying the versions.
EOF
	fi
}

get_checksums
