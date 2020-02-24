compnode() {
	# launch interactive command line session on Partners RC compute node
	# (c) Richard A. Guyer, MD, PhD Feb 24, Jan2020
	#	riguyer@gmail.com rguyer@partners.org
	#
	# To use, copy this function into ~/.bashrc
	#
	# default options:
	mem_needed=8000
	cores_needed=4

	# handle parameters
	while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
	  -m | --mem )
		shift; mem_needed=$1
	    	;;
	  -c | --cores )
	   	shift; cores_needed=$1
	    	;;
		-h | --help )
	    echo This function launches an interactive command line session on a
			echo compute node on the Partners RC cluster.
			echo default:	memory 8000mb, 4 cores
			echo '  '
			echo 'Usage: compnode <options>'
			echo '  '
			echo options:
			echo '	-h | --help:			show this message'
			echo '	-m | --mem:			memory required'
			echo '	-c | --cores:			cores required'
			echo '  '
			kill -INT $$
	    	;;
	esac; shift; done
	if [[ "$1" == '--' ]]; then shift; fi

	echo launching interative command line session on a compute node
	echo cores requested= ${cores_needed}
	echo memory requested= ${mem_needed}
	echo '   '

	bsub -Is \
			-R "rusage[mem=${mem_needed}]" \
			-n ${cores_needed} \
			/bin/bash
}
