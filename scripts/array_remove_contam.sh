#!/bin/bash
#SBATCH -A naika031
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=8gb
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=scot0854@umn.edu
#SBATCH --time=1:00:00
#SBATCH -p msismall,msilarge
#SBATCH -o %A_%a.out
#SBATCH -e %A_%a.err
#SBATCH --array=2-22

set -ue
set -o pipefail

line=${SLURM_ARRAY_TASK_ID}
sample_file=raw_fastq.txt
tempdir=/scratch.global/scot0854/lawsonia
species=Lawsonia
instrument=NextSeq
mouse=/common/bioref/ensembl/main/Mus_musculus_c57bl6nj-113/C57BL_6NJ_v1/bwa/genome
myco=/projects/standard/naika031/shared/ref_genomes/m_hyorhinis/GCF_900476065.1_50465_F02_genomic.fna.gz
ref_fasta=/projects/standard/naika031/shared/ref_genomes/lawsonia/PHE_MN1-00/GCF_000055945.1_ASM5594v1_genomic.fna.gz
read=$(awk -v val="$line" 'NR == val { print $0}' $sample_file)
strain=$(basename -s .fastq.gz $read)

# Load modules for trimming and aligning
module use /projects/standard/naika031/shared/modulefiles.local

module load bbmap
module load bwa
module load samtools

# Check for/create output directories
mkdir -p "${tempdir}"/{trimmed_fastq,cleaned_mouse,cleaned_myco} bam

# JGI BBTools data preprocessing guidelines:
## trim adapters
bbduk.sh in="${read}" \
out="${tempdir}"/trimmed_fastq/"${strain}"_trim_adapt.fq \
ref=adapters ktrim=r k=23 mink=11 hdist=1 ftm=5 tpe tbo

## contaminant filtering per bbduk user guide
bbduk.sh in="${tempdir}"/trimmed_fastq/"${strain}"_trim_adapt.fq \
out="${tempdir}"/trimmed_fastq/"${strain}"_unmatched.fq \
outm="${tempdir}"/trimmed_fastq/"${strain}"_matched.fq \
ref=phix,artifacts k=31 hdist=1 stats=lawsonia/qc_logs/"${strain}"_phistats.txt

## quality trimming (bbduk user guide recommends this as separate step from adapter trimming)
bbduk.sh in="${tempdir}"/trimmed_fastq/"${strain}"_unmatched.fq \
out="${tempdir}"/trimmed_fastq/"${strain}"_trimmed.fq \
qtrim=rl trimq=10

# Successive alignment to remove contaminants and align clean reads to ref
# Including sample information to ensure unique read groups if freebayes is used
bwa mem -t 8 -R "@RG\tID:${species}_${strain}\tPL:ILLUMINA\tPM:${instrument}\tSM:${strain}" \
"${mouse}" "${tempdir}"/trimmed_fastq/"${strain}"_trimmed.fq \
| samtools sort -l 0 -T "${strain}" -@8 - \
 > "${tempdir}"/cleaned_mouse/"${strain}"_nomouse.bam

samtools index "${tempdir}"/cleaned_mouse/"${strain}"_nomouse.bam

samtools view -b -f 4 "${tempdir}"/cleaned_mouse/"${strain}"_nomouse.bam \
| samtools fastq > "${tempdir}"/cleaned_mouse/"${strain}"_nomouse.fastq

bwa mem -t 8 -R "@RG\tID:${species}_${strain}\tPL:ILLUMINA\tPM:${instrument}\tSM:${strain}" \
"${myco}" "${tempdir}"/cleaned_mouse/"${strain}"_nomouse.fastq \
| samtools sort -l 0 -T "${strain}" -@8 - \
 > "${tempdir}"/cleaned_myco/"${strain}"_nomyco.bam

samtools index "${tempdir}"/cleaned_myco/"${strain}"_nomyco.bam

samtools view -b -f 4 "${tempdir}"/cleaned_myco/"${strain}"_nomyco.bam \
| samtools fastq > "${tempdir}"/cleaned_myco/"${strain}"_clean.fastq

bwa mem -t 8 -R "@RG\tID:${species}_${strain}\tPL:ILLUMINA\tPM:${instrument}\tSM:${strain}" \
"${ref_fasta}" "${tempdir}"/cleaned_myco/"${strain}"_clean.fastq \
| samtools sort -l 0 -T "${strain}" -@8 - \
| samtools markdup -@8 - bam/"${strain}"_trimmed_bwa_sorted_markdup.bam

samtools index bam/"${strain}"_trimmed_bwa_sorted_markdup.bam

# basic alignment stats
samtools flagstat bam/"${strain}"_trimmed_bwa_sorted_markdup.bam \
> qc_logs/"${strain}"_trimmed_bwa_sorted_markdup.stdout
