#! /usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)

alignmentFile <- args[1]
geneInfoFile <- args[2]
outputFile <- args[3]

load(alignmentFile)
load(geneInfoFile)

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

id <- genes %in% as.character(G$GeneID)
genes <- genes[id]
strand <- strand[id]
Annot.custom <- subset(G, as.character(GeneID) %in% genes)
rownames(Annot.custom) <- Annot.custom$GeneID
Annot.custom <- Annot.custom[genes,]
rownames(Annot.custom) <- names(genes)
Annot.custom$strand <- strand[match(rownames(Annot.custom), names(genes))]

save(Annot.custom, file=outputFile)
