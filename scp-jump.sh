scp-jump() {
	# copy files from local working directory to remote servers
	# by jumping an ssh connection. Can download with -r option.
	#
	# (c) Richard A. Guyer, MD, PhD Feb 12, 2020
	# riguyer@gmail.com rguyer@mgh.harvard.edu
	#
	# usage: scp-jump <options> <remote dir> [FILES]
	#
	# ssh connection must already be open to host you will jump through.
	# defaults set to use parnters healthare ssh and erisone server, reset
	# defaults as needed.
	#
	# defaults: 			jump=partners
	#				sshlogon=erisone
	#				local=${PWD}
	#				send=1
	files=()
	send=1
	jump=partners
	sshlogin=erisone
	local=${PWD}

	while [[ "$1" =~ ^- ]]; do case $1 in
		-r | --receive )
		send=0; shift
				;;
		-j | --jump )
		shift; jump=$1; shift;
				;;
		-l | --login )
		shift; sshlogin=$1; shift;
				;;
		-loc | --local )
		shift; local=$1; shift;
				;;
		-h | --help )
			echo This function copies files to/from a remote host via scp and ProxyJump.
			echo Default jump ssh.partners.org to erisone.partners.org
			echo Uploading to remote server from local working dir is default setting
			echo '  '
			echo ssh connection to the jumped server must already be open
			echo '  '
			echo 'Usage: scp-jump <options> [remote directory] [FILES]'
			echo '  '
			echo Options:
			echo '	-h, --help	show this message'
			echo '	-r, --receive	download files to local working directory'
			echo '	-j, --jump	ssh connection to jump, user@remote.server'
			echo '	-l, --login	user@remote.server'
			echo '	-loc, --local	local location to download to/upload from'
			echo '  '
			kill -INT $$
				;;
	esac; done

	remote=$1; shift

	while [[ $1 != "" ]]; do
		files=(${files[@]} $1)
		shift
	done

	if [[ ${send} == 1 ]]; then
		num_files=${#files[@]}
		for ((i = 0 ; i < ${num_files} ; i++)); do
			files[i]="${local}/${files[i]}"
		done
		scp -o "ProxyJump ${jump}" ${files[@]} ${sshlogin}:${remote}
	else
		num_files=${#files[@]}
		for ((i = 0 ; i < ${num_files} ; i++)); do
			files[i]="${sshlogin}:${remote}/${files[i]}"
		done
		scp -o "ProxyJump ${jump}" ${files[@]} ${local}
	fi
}
