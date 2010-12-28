#! /usr/bin/env Rscript

fileNames <- commandArgs(trailingOnly=TRUE)
pslFile.RData <- fileNames[1]
geneInfoFile <- gsub("^(.*)\\.psl\\.RData$", "\\1.gene_info.RData", pslFile.RData)

load(pslFile.RData)
psl <- subset(psl, score == 1)
genes <- with(psl, tapply(geneID, probeset, function(x) {
  ans <- unique(x)
  if(length(ans) > 1) {
    return(NA_character_)
  } else {
    return(ans)
  }
}))
genes <- genes[!is.na(genes)]

save(genes, file=geneInfoFile)
