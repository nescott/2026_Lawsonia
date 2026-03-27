#!/bin/bash
#SBATCH -A naika031
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16gb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=scot0854@umn.edu
#SBATCH --time=2:00:00
#SBATCH -p msismall,msilarge,msibigmem
#SBATCH -o %j.out
#SBATCH -e %j.err

set -ue
set -o pipefail

# Use local modules
module use /projects/standard/naika031/shared/modulefiles.local

# Load modules
module load snippy

samples=../scripts/snippy_input.tab
ref=../../ref_genomes/lawsonia/PHE_MN1-00/GCF_000055945.1_ASM5594v1_genomic.gbff
cpus=8
mem=16

snippy-multi \
    "${samples}" \
    --ref "${ref}" \
    --cpus "${cpus}" \
    --ram "${mem}" \
    > lawsonia_runs.sh

bash ./lawsonia_runs.sh
