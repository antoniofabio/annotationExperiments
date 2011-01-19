#! /usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)
inputFileName <- args[1]
outputFileName <- args[2]

A <- read.delim(inputFileName, header=TRUE, as.is=TRUE)

A$date <- sub("^.* +([0-9]?[0-9]-[A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9])$",
              "\\1", A$LOCUS)
A$size.bp <- as.numeric(sub("^.*? +([0-9]+) bp +.*$", "\\1", A$LOCUS))
Sys.setlocale("LC_TIME", "C")
A$date <- as.Date(A$date, "%d-%b-%Y")
rownames(A) <- A$ACCESSION

gene_info <- A

G <- unique(subset(gene_info, select=c(GeneID, symbol)))
G <- cbind(G, subset(gene_info, select=c(synonym, DEFINITION, chromosome, map, size.bp, date, ACCESSION))[rownames(G), ])

disambiguate <- function(G, varName) {
  v <- G[[varName]]
  dup <- v[duplicated(v)]
  if(length(dup) == 0) {
    return(G)
  }
  A <- subset(G, !(v %in% dup))
  B <- subset(G, v %in% dup)
  B <- do.call(rbind, by(B, list(B[[varName]]),
                         function(D) {
                           if(!any(duplicated(D$date))) {
                             D[which.max(D$date),]
                           } else {
                             D
                           }
                         }))
  rbind(A, B)
}
G <- disambiguate(disambiguate(G, "GeneID"), "symbol")

save(gene_info, G, file=outputFileName)
