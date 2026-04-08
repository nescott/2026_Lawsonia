#!/bin/bash
#SBATCH -A naika031
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=248gb
#SBATCH --time=1:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=scot0854@umn.edu
#SBATCH --output=%A_%a.out
#SBATCH --error=%A_%a.err
#SBATCH -p msismall,msilarge,msibigmem
#SBATCH --array=8

sample_file=cleaned_fastq.txt
line=${SLURM_ARRAY_TASK_ID}
centrifuge_home=/projects/standard/naika031/shared/software.install/centrifuge-1.0.3-beta
db=/users/0/scot0854/centrifuge_index/ncbi_nt/nt
out=centrifuge_output/cleaned
module load python

read=$(awk -v val="$line" 'NR == val { print $0}' $sample_file)
strain=$(basename -s _clean.fastq.gz $read)

mkdir -p "${out}"/"${strain}"

srun "${centrifuge_home}"/centrifuge \
    -p 8 \
    -x "${db}" \
    -U "${read}" \
    -S "${out}"/"${strain}"/"${strain}"_centrifuge.txt \
    --report-file "${out}"/"${strain}"/"${strain}"/centrifuge_report.tsv

srun "${centrifuge_home}"/centrifuge-kreport \
    -x "${db}" \
    "${out}"/"${strain}"/"${strain}"_centrifuge.txt > \
    "${out}"/"${strain}"/"${strain}"_kreport.txt
