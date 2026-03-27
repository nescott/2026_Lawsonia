#!/bin/bash
#SBATCH -A naika031
#SBATCH --nodes=1
#SBATCH --mem=800mb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=scot0854@umn.edu
#SBATCH -t 20
#SBATCH -p msismall,msilarge
#SBATCH -o %A_%a.out
#SBATCH -e %A_%a.err
#SBATCH --array=2-16

set -ue
set -o pipefail

line=${SLURM_ARRAY_TASK_ID}
sample_file=cleaned_fastq.txt
target=600000

read=$(awk -v val="$line" 'NR == val { print $0}' $sample_file)
strain=$(basename -s _clean.fastq.gz $read)

# Load modules for trimming and aligning
module use modulefiles.local

module load bbmap

# Check for/create output directories
mkdir -p fastq/subsample

reformat.sh \
    in="${read}" \
    out=fastq/subsample/"${strain}"_clean_subsampled.fastq \
    upsample=f \
    samplereadstarget="${target}"
