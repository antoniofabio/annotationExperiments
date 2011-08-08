#! /usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)

expressionFile <- args[1]
annotationFile <- args[2]
outputFile <- args[3]

load(expressionFile)
load(annotationFile)

X <- X[, rownames(Annot.custom)]
sds <- colMeans(X^2) - colMeans(X)^2
probesets2symbol.strand <- tapply(sds, Annot.custom$symbol.strand,
                                  function(x) names(which.max(x)))

X <- X[,probesets2symbol.strand]
colnames(X) <- names(probesets2symbol.strand)

save(X, probesets2symbol.strand, file=outputFile)
