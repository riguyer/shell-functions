# shell script for making LSF scripts for combining 10X runs from multiple GEM wells
#   intended to run as subsidiary of parallel_combine.sh
#
# NB: this script WILL overwrite any preexisting .lsf file in ./scripts with the name
#   sample.lsf
#
# USAGE: bash make_lsf.sh spec sample {run directories}
#   spec : "-hs" for human sample, "-mm" for mouse sample
#   sample : sample ID
#   {run directories} : list of locations within the base directory where output of each 10X run is located
#
# (c) 2020 Richard A. Guyer, MD, PhD
# rguyer@mgh.harvard.edu
# riguyer@gmail.com
# Goldstein Lab, MGH Pediatric Surgical Research Laboratories

base_dir=${PWD} # script works from the assumption this is a parent directory containing Cell Ranger output from each flow cell
lsf_dir=${base_dir}/scripts
output_dir=${base_dir}/combined
spec=$1; shift
samp=$1; shift
samp_lsf=${lsf_dir}/${samp}.lsf
declare -a run_dirs=(); while [[ $# > 0 ]]; do run_dirs+=($1); shift; done

declare refpath
if [[ "${spec}" == "-mm" ]]; then
  refpath=/data/goldsteinlab/Data/Richard_Guyer/refgenomes/refdata-cellranger-mm10-3.0.0
elif [[ "${spec}" == "-hs" ]]; then
  refpath=/data/goldsteinlab/Data/Richard_Guyer/refgenomes/refdata-cellranger-GRCh38-3.0.0
else
  echo "Must provide species code -hs or -mm as the first option passed to make_lsf.sh"
  exit 1
fi

if [[ ! -d ${lsf_dir} ]]; then mkdir ${lsf_dir}; fi
if [[ -e ${samp_lsf} ]]; then rm ${samp_lsf}; fi
touch ${samp_lsf}

# create LSF script
echo "#!/bin/bash" >> ${samp_lsf}
echo "#BSUB -J ${samp}" >> ${samp_lsf}
echo "#BSUB -o ${samp}.out" >> ${samp_lsf}
echo "#BSUB -e ${samp}.err" >> ${samp_lsf}
echo "#BSUB -q big" >> ${samp_lsf}
echo "#BSUB -n 6" >> ${samp_lsf}
echo "#BSUB -R rusage[mem=32000]" >> ${samp_lsf}
echo "" >> ${samp_lsf}
echo "module load cellranger/3.0.2" >> ${samp_lsf}
echo "function join { local IFS=\"\$1\"; shift; echo \"\$*\"; }" >> ${samp_lsf}
echo "" >> ${samp_lsf}
echo "cd ${output_dir}" >> ${samp_lsf}
echo "" >> ${samp_lsf}
echo "declare -a fastq_dirs=()" >> ${samp_lsf}
echo "for r in ${run_dirs[@]}; do" >> ${samp_lsf}
echo "  run_fastqs=${base_dir}/\${r}/fastq/SUB09880/${samp}" >> ${samp_lsf}
echo "  fastq_dirs+=(\${run_fastqs})" >> ${samp_lsf}
echo "done" >> ${samp_lsf}
echo "" >> ${samp_lsf}
echo "cellranger count --id=${samp} \\" >> ${samp_lsf}
echo "  --fastqs=\$(join , \${run_fastqs[@]}) \\" >> ${samp_lsf}
echo "  --transcriptome=${refpath} \\" >> ${samp_lsf}
echo "  --chemistry=auto \\" >> ${samp_lsf}
echo "  --nosecondary" >> ${samp_lsf}
