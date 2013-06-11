#!/bin/bash
#
# FHEM Git Connection Script
#

. fhem.git.cfg

set -e

if [ -z "${FHEM_GIT_URL}" ]; then
	echo "ERROR: No Git URL set in fhem.git.cfg. Aborting ..."
	exit 1
else
	# extract the protocol
	GIT_PROTO="$(echo ${FHEM_GIT_URL} | grep :// | sed -e's,^\(.*://\).*,\1,g')"
	# remove the protocol
	GIT_URL="$(echo ${FHEM_GIT_URL/${GIT_PROTO}/})"
	# extract the user (if any)
	GIT_USER="$(echo ${GIT_URL} | grep @ | cut -d@ -f1)"
	# extract the host
	GIT_HOST="$(echo ${GIT_URL/${GIT_USER}@/} | cut -d/ -f1)"
	# extract the path (if any)
	GIT_PATH="$(echo ${GIT_URL} | grep / | cut -d/ -f2-)"
fi

# Remove Git remote reference
#
GIT_REMOTE="`git remote`"
if [[ x"${GIT_REMOTE}" != x"" ]]; then
	for _REMOTE in ${GIT_REMOTE}; do
		git remote rm ${_REMOTE}
	done
fi

# Handle specific files as unchanged = keep local versions
git update-index --assume-unchanged fhem.git.cfg
git update-index --assume-unchanged db.conf

case $1 in
  pull)

	# Setup Git user credentials for login
	#
	if [ ! -z "${FHEM_GIT_USER}" -a ! -z "${FHEM_GIT_PASSWORD}" ]; then
		echo "machine ${GIT_HOST}
login ${FHEM_GIT_USER}
password ${FHEM_GIT_PASSWORD}
" >  ~/.netrc
	fi

	# Backup Git configuration
	#
	cp -f fhem.git.cfg /tmp/fhem.git.cfg
	cp -f db.conf /tmp/db.conf

	# Reset Git files
	#
	git reset --hard HEAD

	# Add Git remote reference
	#
	git remote add -t master origin "${FHEM_GIT_URL}"

	# Get updates
	#
	set +e
	c=1
	while [[ $c -le 5 ]]; do
		git remote update
		if [ "$?" = "0" ]
			then
			break;
		else
			[[ $c -eq 5 ]] && exit 1
			(( c++ ))
			echo "$c. try in 3 seconds ..."
			sleep 3
		fi
	done

	c=1
	while [[ $c -le 5 ]]; do
		git pull origin master
		if [ "$?" -eq "0" ]
			then
			break;
		else
			[[ $c -eq 5 ]] && exit 1
			(( c++ ))
			echo "$c. try in 3 seconds ..."
			sleep 3
		fi
	done
	set -e

	# Restore Git configuration
	#
	mv -f /tmp/fhem.git.cfg fhem.git.cfg
	mv -f /tmp/db.conf db.conf
  ;;
	
  push)

	# Setup Git user credentials for login
	#
	if [[ x"${FHEM_GIT_USER}" == x"" || x"${FHEM_GIT_PASSWORD}" == x"" ]]; then
		echo "Git credentials not found in fhem.git.cfg. Aborting ..."
		exit 1
	else
		echo "machine ${GIT_HOST}
login ${FHEM_GIT_USER}
password ${FHEM_GIT_PASSWORD}
" >  ~/.netrc
	fi

	set +e

	# Commit changes
	git commit -a -m "FHEM Git auto-commit"

	# Add Git remote reference
	#
	git remote add -t master origin "${FHEM_GIT_URL}"
	
	# Push changes to remote Git
	c=1
	while [[ $c -le 5 ]]; do
		git push origin master
		if [ "$?" -eq "0" ]
			then
			break;
		else
			[[ $c -eq 5 ]] && exit 1
			(( c++ ))
			echo "$c. try in 3 seconds ..."
			sleep 3
		fi
	done
	set -e

  ;;

  *)
	echo "Usage: $0 [ pull | push ]"
	exit 1
  ;;
esac

rm -rf ~/.netrc

# Remove Git remote reference
#
GIT_REMOTE="`git remote`"
if [[ x"${GIT_REMOTE}" != x"" ]]; then
	for _REMOTE in ${GIT_REMOTE}; do
		git remote rm ${_REMOTE}
	done
fi

# Correct file permissions
#
OWNER="`ls -l fhem.pl | awk '{ print $3 }'`"
chown ${OWNER} . -R
