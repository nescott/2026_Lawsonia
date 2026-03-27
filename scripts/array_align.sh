#!/bin/bash
#SBATCH -A naika031
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=2gb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=scot0854@umn.edu
#SBATCH -t 20
#SBATCH -p msismall,msilarge
#SBATCH -o %A_%a.out
#SBATCH -e %A_%a.err
#SBATCH --array=1-17

set -ue
set -o pipefail

line=${SLURM_ARRAY_TASK_ID}
sample_file=scripts/subsample_fastq.txt
species=Lawsonia
instrument=NextSeq
ref_fasta=/projects/standard/naika031/shared/ref_genomes/lawsonia/PHE_MN1-00/GCF_000055945.1_ASM5594v1_genomic.fna.gz
cores=4

read=$(awk -v val="$line" 'NR == val { print $0}' $sample_file)
strain=$(basename -s _clean_subsampled.fastq $read)

module load bwa
module load samtools

mkdir -p bam/subsampled

bwa mem -t "${cores}" -R "@RG\tID:${species}_${strain}\tPL:ILLUMINA\tPM:${instrument}\tSM:${strain}" \
"${ref_fasta}" "${read}" \
| samtools sort -l 0 -T "${strain}" -@"${cores}" - \
| samtools markdup -@"${cores}" - bam/subsampled/"${strain}"_bwa_subsample.bam

samtools index bam/subsampled/"${strain}"_bwa_subsample.bam

# basic alignment stats
samtools flagstat bam/subsampled/"${strain}"_bwa_subsample.bam \
> qc_logs/"${strain}"_bwa_subsample.stdout
