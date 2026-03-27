#!/bin/bash
#SBATCH -A naika031
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=6gb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=scot0854@umn.edu
#SBATCH --time=4:00:00
#SBATCH -p msismall,msilarge
#SBATCH -o %j.out
#SBATCH -e %j.err

set -ue
set -o pipefail

temp_dir=/scratch.global/scot0854/lawsonia/
bam_dir=bam/
tax_dir=centrifuge_output/cleaned/
qc_dir=qc_logs/
out=cleaned_multiqc

file_name="$(date +%F)_cleaned_qc"

# Use local modules
module use /projects/standard/naika031/shared/modulefiles.local

# Load modules
module load fastqc
module load qualimap
module load multiqc

# trimmed fastq quality
find "$temp_dir" -name "*_trimmed.fq" -exec fastqc  -t 8 "$temp_dir" {} \;
find "$temp_dir" -name "*_clean.fastq.gz"  -exec fastqc  -t 8 "$temp_dir" {} \;

# bam qc
unset DISPLAY # qualimap won't work on cluster without this
find "$bam_dir" -name "*.bam" \
  -exec qualimap bamqc -bam {} -outdir $temp_dir/{} --java-mem-size=4G  \;

# multiqc
multiqc "${temp_dir}" "${tax_dir}" "${qc_dir}" --ignore "${temp_dir}"/exclude -o "${out}" -n "$file_name"
