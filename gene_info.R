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


save(gene_info, file=outputFileName)
