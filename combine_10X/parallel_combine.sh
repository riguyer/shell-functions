# shell script for combining 10X runs from multiple GEM wells in parallel on the ERISone cluster
#
# USAGE: bash parallel_combine.sh -hs {human samples} -mm {mouse samples}
#
# (c) 2020 Richard A. Guyer, MD, PhD
# rguyer@mgh.harvard.edu
# riguyer@gmail.com
# Goldstein Lab, MGH Pediatric Surgical Research Laboratories

base_dir=${PWD} # script works from the assumption this is a parent directory containing Cell Ranger output from each flow cell
output_dir=${base_dir}/combined
run_dirs=(Run1 Run2) # no limit to number of runs you can include
lsf_dir=${base_dir}/scripts

if [[ ! -d ${output_dir} ]]; then
  mkdir ${output_dir}
fi

declare spec samp
while [[ $# > 0 ]]; do
  if [[ "$1" == "-hs" ]]; then
    spec="-hs"; shift
  elif [[ "$1" == "-mm" ]]; then
    spec="-mm"; shift
  else
    samp=$1; shift
    bash ./make_lsf.sh ${spec} ${samp} ${run_dirs[@]}
    bsub -q big < ${lsf_dir}/${samp}.lsf
    echo ${samp}.lsf created and submitted to LSF scheduler
    echo .lsf file located at: ${lsf_dir}/${samp}.lsf
  fi
done
