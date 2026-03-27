#!/bin/bash
#SBATCH -A naika031
#SBATCH --nodes=1
#SBATCH --mem=12G
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=scot0854@umn.edu
#SBATCH -t 20
#SBATCH -p msismall,msilarge,msibigmem
#SBATCH -o %A_%a.out
#SBATCH -e %A_%a.err
#SBATCH --array=2-22

set -ue
set -o pipefail

module use /projects/standard/naika031/shared/modulefiles.local
module load mash

line=${SLURM_ARRAY_TASK_ID}
sample_file=cleaned_fastq.txt

read=$(awk -v val="$line" 'NR == val { print $0}' $sample_file)
sample=$(basename -s _clean.fastq.gz $read)
ref=dist/lawsonia_genomes.msh

mash dist "${ref}" "${read}" | sort -k 3,3n > dist/"${sample}"_dist.txt
