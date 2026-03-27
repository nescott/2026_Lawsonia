## Purpose: clean and merge variant table with annotations
## Author: Nancy Scott
## Email: scot0854@umn.edu

library(tidyverse)

isolate_list <- list.files("~/Google Drive/My Drive/02_VDL/03_Lawsonia/snippy/",
                           full.names = TRUE)
isolate_list <- isolate_list[grep("core", isolate_list, invert=TRUE)]

core_snps <- read.delim("~/Google Drive/My Drive/02_VDL/03_Lawsonia/snippy/core.tab")

# Source - https://stackoverflow.com/a
# Posted by m0nhawk
# Retrieved 2026-01-15, License - CC BY-SA 3.0

dataset <- do.call("rbind", lapply(isolate_list, FUN = function(file) {
    read.delim(file, header=TRUE)
}))

dataset <- dataset %>% 
    filter(TYPE=="snp") %>% 
    select(-EVIDENCE) %>% 
    arrange(CHROM,POS) %>% 
    distinct()

annotated_snps <- core_snps %>%
    left_join(dataset, join_by(CHR==CHROM, POS, REF))

dups <- as.data.frame(annotated_snps %>% 
                          group_by(CHR,POS) %>%
                          count() %>%
                          filter(n>1))

multi_allelic_annotations <- annotated_snps %>% right_join(dups)
write.csv(annotated_snps, "annotated_snippy_core_variants.csv")
