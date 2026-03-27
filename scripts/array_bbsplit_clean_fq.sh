#!/bin/bash
#SBATCH -A naika031
#SBATCH --nodes=1
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=scot0854@umn.edu
#SBATCH --time=3:00:00
#SBATCH -p msismall,msilarge,msibigmem
#SBATCH -o %A_%a.out
#SBATCH -e %A_%a.err
#SBATCH --array=2-22

set -ue
set -o pipefail

module use /projects/standard/naika031/shared/modulefiles.local
module load bbmap/38.94
module load htslib

mkdir -p fastq/logs \
    fastq/mouse \
    fastq/myco \
    fastq/clean

line=${SLURM_ARRAY_TASK_ID}
sample_file=raw_fastq.txt
mouse=/projects/standard/naika031/shared/ref_genomes/mouse/C57BL_6NJ_v1.fa
myco=/projects/standard/naika031/shared/ref_genomes/m_hyorhinis/GCF_900476065.1_50465_F02_genomic.fna.gz

read=$(awk -v val="$line" 'NR == val { print $0}' $sample_file)
sample=$(basename -s .fastq.gz $read)

bbsplit.sh \
    in="${read}" \
    ref_1="${mouse}" \
    ref_2="${myco}" \
    refstats=fastq/logs/"${sample}"_alignment.txt \
    out_1=fastq/mouse/"${sample}"_mouse.fastq \
    out_2=fastq/myco/"${sample}"_myco.fastq \
    outu=fastq/clean/"${sample}"_clean.fastq

bgzip fastq/clean/"${sample}"_clean.fastq
bgzip fastq/mouse/"${sample}"_mouse.fastq
bgzip fastq/myco/"${sample}"_myco.fastq
