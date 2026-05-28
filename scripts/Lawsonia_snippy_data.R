## Purpose: Join annotations to snippy core variants and summarize
## Author: Nancy Scott
## Email: scot0854@umn.edu

## load packages----
library(tidyverse)

## read in snippy tables----
isolate_list <- list.files("../snippy",
                           full.names = TRUE, recursive = TRUE)
isolate_list <- isolate_list[grep("_snps.tab", isolate_list)]

core_snps <- read.delim("../snippy/core.tab")

## merge with annotation----
# Source - https://stackoverflow.com/a
# Posted by m0nhawk
# Retrieved 2026-01-15, License - CC BY-SA 3.0

dataset <- do.call("rbind", lapply(isolate_list, FUN = function(file) {
    read.delim(file, header=TRUE, na.strings = "")
}))

dataset <- dataset %>% 
    filter(TYPE=="snp") %>% 
    select(-EVIDENCE) %>% 
    arrange(CHROM,POS) %>% 
    distinct()

annotated_snps <- core_snps %>%
    left_join(dataset, 
              join_by(CHR==CHROM, POS, REF))

annotated_snps <- annotated_snps %>%
  separate_wider_delim(EFFECT, 
                       " ", 
                       names = c("EFFECT","NT_CHANGE", "AA_CHANGE"),
                       too_few = "align_start")


## look for multi-allelic SNPs----
dups <- as.data.frame(annotated_snps %>% 
                          group_by(CHR,POS) %>%
                          count() %>%
                          filter(n>1))

multi_allelic_annotations <- annotated_snps %>% right_join(dups)
#write.csv(annotated_snps, "annotated_snippy_core_variants.csv")

## data exploration----
# sum by variant type
var_counts <- annotated_snps %>%
  group_by(EFFECT) %>%
  tally()

# what's going on with the intergenic SNPs?
intergenic <- annotated_snps %>%
  filter(is.na(EFFECT))

# how many genes/locus tags affected?
affected_gene_count <- nrow(annotated_snps %>% filter(!is.na(LOCUS_TAG)) %>%
                              group_by(LOCUS_TAG) %>%
                              tally())

# how many *core* SNPs between PHElow and PHEhigh?
PHE_core_diff_count <- nrow(annotated_snps %>%
                              filter(PHElow_passage != PHEhigh_passage))

# how many core SNPs in Ham1?
ham1_core_snp_count <- nrow(annotated_snps %>%
                              filter(Ham1 != REF))
# how many affected genes in Ham1?
ham1_affected_gene_count <- nrow(annotated_snps %>%
                                   filter(Ham1 != REF) %>%
                                   group_by(LOCUS_TAG) %>%
                                   tally())

# how many core SNPs in F1196?
f1196_core_snp_count <- nrow(annotated_snps %>%
                               filter(F1196 != REF))
# how many affected genes in F1196?
f1196_affected_gene_count <- nrow(annotated_snps %>%
                                    filter(F1196 != REF) %>%
                                    group_by(LOCUS_TAG) %>%
                                    tally())

# how many core SNPs between Ham1 and F1196?
ham1_v_f1196_snp_count <- nrow(annotated_snps %>%
                                 filter(Ham1 != F1196))
ham1_v_f1196_affected_gene_count <- nrow(annotated_snps %>%
                                           filter(Ham1 !=F1196) %>%
                                           group_by(LOCUS_TAG) %>%
                                           tally())


