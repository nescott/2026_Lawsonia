#!/bin/bash
#SBATCH -A naika031
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=4gb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=scot0854@umn.edu
#SBATCH --time=4:00:00
#SBATCH -p msismall,msilarge
#SBATCH -o %j.out
#SBATCH -e %j.err

set -ue
set -o pipefail

fq_dir=lawsonia_fastq/raw/
tax_dir=centrifuge_output/
out=multiqc

file_name="$(date +%F)_raw_qc"

# Use local modules
module use /projects/standard/naika031/shared/modulefiles.local

# Load modules
module load fastqc
module load multiqc

mkdir -p "${qc_dir}"

# raw fastq file qc
find "$fq_dir" -name "*fastq.gz" -exec fastqc  -t 8 "$qc_dir" {} \;

# multiqc
multiqc "${fq_dir}" "${tax_dir}"  -o "${out}" -n "$file_name"
