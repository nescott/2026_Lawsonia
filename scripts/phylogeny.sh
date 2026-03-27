#!/bin/bash
#SBATCH -A naika031
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=16gb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=scot0854@umn.edu
#SBATCH --time=1:00:00
#SBATCH -p msismall,msibigmem,msilarge
#SBATCH -o %j.out
#SBATCH -e %j.err

set -ue
set -o pipefail

seed=17
bootstrap=1000
in_file=Lawsonia_N343_ann_filt_sort.min17.phy
threads=16
out_file=Lawsonia_17

module load raxml/8.2.11_pthread

raxml \
    -f a \
    -m ASC_GTRCAT \
    --asc-corr=lewis \
    -V \
    -p "${seed}" \
    -x "${seed}" \
    -# "${bootstrap}" \
    -s "${in_file}" \
    -T "${threads}" \
    -n "${out_file}"
