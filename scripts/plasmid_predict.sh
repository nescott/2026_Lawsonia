#!/bin/bash
#SBATCH -A naika031
#SBATCH --nodes=1
#SBATCH --mem=100gb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=scot0854@umn.edu
#SBATCH --time=0:20:00
#SBATCH -p msismall,msilarge,msibigmem
#SBATCH -o %A_%a.out
#SBATCH -e %A_%a.err
#SBATCH --array=3-17

set -ue
set -o pipefail

line=${SLURM_ARRAY_TASK_ID}
sample_file=lawsonia_graphs.txt

db=/scratch.global/scot0854/lawsonia/general_plasmid_db

gfa=$(awk -v val="$line" 'NR == val { print $0}' $sample_file)
strain=$(echo $gfa | cut -d "/" -f 8)

mkdir "${strain}"

cd "${strain}"

# Use local modules
module use /projects/standard/naika031/shared/modulefiles.local

# Load modules
module load gplasCC

gplas -i "${gfa}" -p "${db}" -n "${strain}"
