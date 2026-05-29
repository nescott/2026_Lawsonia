#!/bin/bash
#SBATCH -A naika031
#SBATCH --nodes=1
#SBATCH --mem=500mb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=scot0854@umn.edu
#SBATCH --time=0:15:00
#SBATCH -p msismall,msilarge,msibigmem
#SBATCH -o %A_%a.out
#SBATCH -e %A_%a.err
#SBATCH --array=2-17

set -ue
set -o pipefail

line=${SLURM_ARRAY_TASK_ID}
sample_file=plasmid_dirs.txt
ref=/projects/standard/naika031/shared/ref_genomes/lawsonia/PHE_MN1-00/GCF_000055945.1_ASM5594v1_genomic.fna

dir=$(awk -v val="$line" 'NR == val { print $0}' $sample_file)

# Load modules
module load blast-plus

cd "${dir}"
files=$(find results -maxdepth 1 -name "*.fasta" | sort)

for f in $files
do
    blastn -query "${f}" -subject "${ref}" -outfmt 6 >> "${dir}"_blast_output.txt
done

awk 'NR > 1 {print $4}' results/"${dir}"_results.tab \
    | sort \
    | uniq \
    > "${dir}"_gplas_contigs.txt

awk '{print $1}' "${dir}"_blast_output.txt \
    | sort \
    | uniq \
    > "${dir}"_gplas_blast.txt

diff "${dir}"_gplas_contigs.txt "${dir}"_gplas_blast.txt \
    > "${dir}"_contigs_not_in_reference.txt
