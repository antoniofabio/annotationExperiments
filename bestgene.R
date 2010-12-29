#! /usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)

usage <- function() {
  message("Reads a '.psl.RData' blat output file (in RData format)
and extracts the best gene ID for each probeset

usage:
./bestgene.R fileName.psl.RData outputFile.RData

 fileName.psl.RData: blat file, converted to RData using 'psl2RData.R'
 outputFile.RData: output file name (default: 'fileName.gene_info.RData')
")
}

cargs <- length(args)
if(cargs < 1 || cargs > 2) {
  message("wrong number of arguments (", cargs, ")\n")
  usage()
  quit(save="no", status=1)
}

pslFile.RData <- args[1]
if(cargs < 2) {
  geneInfoFile <- gsub("^(.*)\\.psl\\.RData$", "\\1.gene_info.RData", pslFile.RData)
} else {
  geneInfoFile <- args[2]
}

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
