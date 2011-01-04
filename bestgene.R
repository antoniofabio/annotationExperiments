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
## psl <- subset(psl, score == 1)
## psl <- subset(psl, strand == "+")
psl$geneStrand <- with(psl, ifelse(strand == "-", paste(geneID, strand, sep="."), geneID))
genes <- by(psl, psl$probeset, function(D) {
  if(length(unique(D$geneStrand))==1) {
    return(D$geneStrand[1])
  }
  scores <- with(D, tapply(matches, geneStrand, sum, na.rm=TRUE))
  scores <- sort(scores, decreasing=TRUE)
  if(scores[1] > 2*scores[2]) {
    return(names(scores)[1])
  } else {
    return(NA_character_)
  }
}, simplify=TRUE)
genes <- genes[!is.na(genes)]
strand <- ifelse(grepl("^[0-9]+\\.-$", genes), "-", "+")
genes <- gsub("^([0-9]+)\\.-$", "\\1", genes)

save(genes, strand, file=geneInfoFile)
