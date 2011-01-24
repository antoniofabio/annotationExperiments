#! /usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)

alignmentFile <- args[1]
geneInfoFile <- args[2]
outputFile <- args[3]

load(alignmentFile)
load(geneInfoFile)

Annot.custom <- data.frame(genes, strand, probeset = names(genes),
                           stringsAsFactors=FALSE)
Annot.custom <- merge(Annot.custom, G,
                      by.x="genes",
                      by.y="row.names",
                      all.x=TRUE,
                      all.y=FALSE)
Annot.custom <- subset(Annot.custom, !is.na(symbol))
Annot.custom$symbol.strand <- with(Annot.custom,
                                   paste(symbol,
                                         ifelse(strand == '-', ' (-)', ''),
                                         sep=""))
rownames(Annot.custom) <- Annot.custom$probeset

save(Annot.custom, file=outputFile)
