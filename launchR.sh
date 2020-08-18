launchR() {
	# launch R from a command line compute node on ERISone cluster
	# (c) Richard A. Guyer, MD, PhD Feb 11
	# riguyer@gmail.com rguyer@mgh.harvard.edu
	#
	# this function will launch the default R instance within the specified
	# conda environment
	#
	# To use, copy this function into ~/.bashrc
	#
	# default options:
	mem_needed=8000
	cores_needed=4
	conda_env=CondaR3.6

	# handle parameters
	while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
	  -m | --mem )
		shift; mem_needed=$1
	    	;;
	  -c | --cores )
	   	shift; cores_needed=$1
	    	;;
	  -e | --env )
	   	shift; conda_env=$1
	    	;;
		-h | --help )
	    echo This function launches a command line instance of R from a
			echo compute node on the Partners RC cluster.
			echo '  '
			echo 'Usage: launchR <options>'
			echo parameters:
			echo '	-h | --help:			show this message'
			echo '	-m | --mem:			memory required'
			echo '	-c | --cores:			cores required'
			echo '	-e | --env:			conda environment (if other than default)'
			echo '  '
			kill -INT $$
	    	;;
	esac; shift; done
	if [[ "$1" == '--' ]]; then shift; fi

	echo launching R from conda environment ${conda_env} by user ${USER}
	echo cores requested= ${cores_needed}
	echo memory requested= ${mem_needed}
	echo '   '

	bsub -Ip \
		-R "rusage[mem=${mem_needed}]" \
		-n ${cores_needed} \
		"module load anaconda; source activate ${conda_env}; R;"
}
