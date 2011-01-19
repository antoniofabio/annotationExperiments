#! /usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)

alignmentFile <- args[1]
geneInfoFile <- args[2]
outputFile <- args[3]

load(alignmentFile)
load(geneInfoFile)

id <- genes %in% as.character(G$GeneID)
genes <- genes[id]
strand <- strand[id]
Annot.custom <- subset(G, as.character(GeneID) %in% genes)
rownames(Annot.custom) <- Annot.custom$GeneID
Annot.custom <- Annot.custom[genes,]
Annot.custom$strand <- strand
rownames(Annot.custom) <- names(genes)
Annot.custom$symbol.strand <- with(Annot.custom,
                                   ifelse(strand == '-', paste(symbol, "(-)"), symbol))

save(Annot.custom, file=outputFile)
