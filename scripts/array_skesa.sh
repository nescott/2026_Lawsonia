#!/bin/bash
#SBATCH -A naika031
#SBATCH --nodes=1
#SBATCH --mem=12G
#SBATCH --cpus-per-task=6
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=scot0854@umn.edu
#SBATCH --time=2:00:00
#SBATCH -p msismall,msilarge,msibigmem
#SBATCH -o %A_%a.out
#SBATCH -e %A_%a.err
#SBATCH --array=10

set -ue
set -o pipefail

module use /projects/standard/naika031/shared/modulefiles.local
module load skesa

line=${SLURM_ARRAY_TASK_ID}
sample_file=cleaned_fastq.txt
cpus=6
mem=12

read=$(awk -v val="$line" 'NR == val { print $0}' $sample_file)
sample=$(basename -s _clean.fastq.gz "$read")

mkdir -p skesa_assembly/"${sample}"

skesa --reads "${read}" \
    --cores "${cpus}" \
    --memory "${mem}" \
    > skesa_assembly/"${sample}"/"${sample}"_skesa.fa

module unload skesa
module load funannotate

funannotate clean \
    -i skesa_assembly/"${sample}"/"${sample}"_skesa.fa \
    -m 100 \
    -o skesa_assembly/"${sample}"/"${sample}"_cleaned.fa
