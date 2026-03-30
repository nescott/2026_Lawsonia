#!/bin/bash
#SBATCH -A naika031
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=8gb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=scot0854@umn.edu
#SBATCH --time=2:00:00
#SBATCH -p msismall,msibigmem,msilarge
#SBATCH -o %j.out
#SBATCH -e %j.err

set -ue
set -o pipefail

align=clean.full.aln
pre=gb_iq
threads=8
tree=iqtree
bootstrap=1000

module use /projects/standard/naika031/shared/modulefiles.local
module load gubbins

run_gubbins.py --prefix "${pre}" \
    --threads "${threads}" \
   --tree-builder "${tree}" \
   --bootstrap "${bootstrap}" \
   --best-model \
    "${align}"
