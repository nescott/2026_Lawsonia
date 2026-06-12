# *Lawsonia intracellularis* isolate genomic analysis

* 22 isolates from 3 host species in 4 countries 
* DNA was extracted following culture in McCoy cells in microaerophilic conditions
* Illumina sequencing performed by UMGC

Isolate | Host | Country | Year | Successful sequencing | Notes
------- | ---- | ------- | ---- | --------------------- | -----
LR_189_5_85 | pig | UK | 1983 | yes | 
916_91 | pig | UK | 1991 | yes | 
F1196 | horse | USA | 1996 | yes | 
D15_540 | pig | Denmark | 1998 | yes | lyophilized vaccine
Frozen_vaccine | pig | USA | 1998 | yes | N343, published genome
Ham1 | hamster | USA| ? | yes | 
PHE_low_passage | pig | USA | 2000 | yes | 18 passages
PHE_high_passage | pig | USA | 2000 | yes | 78 passages
KK_UMN04 | pig | USA | 2004 | yes | 
UMN_04 | pig | USA | 2004 | yes | 
NW | pig | USA | 2005 | yes | NWumn05 
47216 | pig | USA | 2006 | yes |
52477 | pig | USA | 2006 | yes | 
HOFF | pig | USA | 2006 | yes | 
56960 | pig | USA | 2007 | yes |
BE01 | pig | USA | 2008 | yes | 
E5 | pig | Brazil | 2017 | yes | 
VPB4 | pig | USA | 1991 | no | 
1482_89 | pig | ? | ?| no | 
963_93 | pig | UK | 1993 | no | 
E40504 | horse | USA | 2009 | no | published genome
E8 | ? | ? | ? | no | 

## Initial sample processing and QC
Adapter and quality trimming was performed on single-end 150bp fastq files
(BBDuk v38.94), followed by sequencing QC with FastQC(v0.12.1) and taxonomic
classification with Centrifuge (v1.0.4). Sequencing counts ranged from ~2000 
in sample 1482_89 to ~4.1 million in D15_540. The major species identified were 
*L. intracellularis*, *Mus musculus* and *Mycoplasma hyorhinis*. *Lawsonia* 
accounted for the majority of reads in all but 4 of the samples (1482_89, 963_93, 
E8, E40504). These 4 samples had fewer than 40k reads mapping to *Lawsonia* and 
were excluded from further analysis. Sample VBP4 had a majority of *Lawsonia* 
reads but fewer than 60k reads overall and was also excluded.

Fastq files for the remaining 17 isolates were further processed to remove
contaminating mouse and mycoplasma reads before aligning to the PHE/MN1-00
reference genome (RefSeq assembly GCF_000055945.1; see "array_remove_contam.sh").

## Variant detection
### Snippy v4.6.0
Snippy-multi was used to call variants, annotate and generate a core SNP
alignment for all 17 samples against the PHE/MN1-00 reference genome (see
"snippy-multi.sh" and "snippy-input.tab").

## *De novo* assembly and annotation
### SKESA v2.5.1 vs SPAdes v4.0.0
All isolates were assembled with both SPADes and SKESA (see "array_skesa.sh").
Assemblies were cleaned (duplicated contigs removed) using funannotate clean.
All SPAdes assemblies had duplicated contigs (min 33, max 3844) and no SKESA
contigs had duplicates identified by funannotate.

Quality of cleaned assemblies was assessed relative to the reference genome using 
QUAST v4.3. While SPADes produced longer scaffolds, SKESA produced fewer
misassemblies relative to the reference genome.

### PGAP (Prokaryotic Genome Annotation Pipeline), 2025-05-06.build7983
SKESA genome assemblies were annotated using the NCBI PGAP pipeline (run
interactively). As assessed by CheckM, genome completeness ranged from 85.96 to
88.19%, and contamination ranged from 0 to 1.79%.

### gplasCC v1.0.1
gplasCC was used to search for novel plasmids in all isolates, using the SPADes
assembly graphs as input and the general plasmid database from gplasCC (general
= non-species specific). The resulting fasta files of predicted plasmid contigs
were compared to the reference genome using BLAST.

## Population analysis
### PopPUNK v2.7.8
All genomes were clustered using PopPUNK (database created using genome
sketching, database QC, model fitting, and isolates queried).

