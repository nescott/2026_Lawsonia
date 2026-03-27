#!/bin/bash
#SBATCH -A naika031
#SBATCH --nodes=1
#SBATCH --mem=5gb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=scot0854@umn.edu
#SBATCH --time=1:00:00
#SBATCH -p msismall,msilarge
#SBATCH -o %j.out
#SBATCH -e %j.err

set -ue
set -o pipefail

ref_fasta=/projects/standard/naika031/shared/ref_genomes/lawsonia/PHE_MN1-00/GCF_000055945.1_ASM5594v1_genomic.fna
bam_list=subsampled_bam.files
species=Lawsonia
ref=PHE_MN100
snpeff=/projects/standard/naika031/shared/software.install/snpEff/snpEff.jar
snpeff_config=/projects/standard/naika031/shared/software.install/snpEff/snpEff.config
snpeff_db=Lawsonia_PHE_MN1_00

#Load modules
module load freebayes
module load bcftools
module load java/openjdk-21.0.2

#freebayes -f "${ref_fasta}" \
#  -C 5 \
#  -F 0.9 \
#  -p 1 \
#  -L "${bam_list}" \
#  -v "${species}_${ref}.vcf"

#bcftools query -l "${species}_${ref}.vcf" | sort > samples.txt
#bcftools view -S samples.txt "${species}_${ref}.vcf" \
#  -o "${species}_${ref}_sorted.vcf"

#bcftools view -i 'TYPE="snp" & MIN(FMT/DP) > 9 & GT !="mis"' \
#  "${species}_${ref}_sorted.vcf" \
#  -o "${species}_${ref}_sorted_filtered.vcf"

java -Xmx4g -jar "${snpeff}" -c "${snpeff_config}" "${snpeff_db}" \
  "${species}_${ref}_sorted_filtered.vcf" \
  > "${species}_${ref}_sorted_filtered_annotated.vcf"
