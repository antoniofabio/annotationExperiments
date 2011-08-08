#! /usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)

usage <- function() {
  message("Reads a 'gene_info' and a 'psl' files (in RData format)
and counts the number of distinct probes mapping on each target gene.

usage:
./countProbes.R fileName.gene_info.RData fileName.psl.RData outputFile.RData
")
}

cargs <- length(args)
if(cargs < 3) {
  message("wrong number of arguments (", cargs, ")\n")
  usage()
  quit(save="no", status=1)
}

geneInfoFile <- args[1]
pslFile <- args[2]
outputFile <- args[3]

load(geneInfoFile)
message("loading probes alignment info file...")
load(pslFile)
message("done.")

message("preparing data...")
psl <- subset(psl, (probeset %in% names(genes)) & (geneID %in% genes))
psl$gene.strand <- with(psl, paste(geneID, strand, sep = "."))
psl <- subset(psl, select = c(probeset, probe, gene.strand))
message("done.")

cc <- rep(NA_integer_, length(genes))
STEP <- ceiling(length(cc) / 1000)
genes.strand <- paste(genes, strand, sep = ".")
message("start counting...")
for(i in seq_along(cc)) {
  psi <- names(genes)[i]
  gi <- genes.strand[i]
  cc[i] <- with(psl, length(unique(probe[probeset == psi & gene.strand == gi])))
  if((i %% STEP) == 0) {
    message("", round(i*100/length(cc), 1), "% done")
  }
}

tab <- data.frame(probeset = names(genes),
                  gene = as.vector(genes),
                  strand = strand,
                  num.probes = cc,
                  stringsAsFactors = FALSE)

save(tab, file = outputFile)
