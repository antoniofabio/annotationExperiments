#! /usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)
cargs <- length(args)

if(cargs != 2) {
  message("Extract relevant infos from a refseq '.gbff' file,
and stores it into an RData file.

usage:
 ./gbff2RData.R fileName.gbff fileName.RData
")
  quit("no", status=1)
}

dbFileName <- args[1]
outputFileName <- args[2]

lines <- readLines(dbFileName)
blocks.delimiters <- which(lines == "//")
n.blocks <- length(blocks.delimiters)
f <- rep(seq_len(n.blocks), c(blocks.delimiters[1], diff(blocks.delimiters)))
blocks <- split(lines, f)

vars.simple <- c("LOCUS", "DEFINITION", "ACCESSION", "VERSION", "KEYWORDS",
                 "SOURCE")
names(vars.simple) <- vars.simple
vars.simple <- as.list(vars.simple)
getV <- function(block, V) {
  line <- grep(sprintf("^ *%s *", V), block, value=TRUE)[1]
  gsub(sprintf("^ *%s *(.*)$", V), "\\1", line)
}

features <- function(block) {
  block[seq(grep("^FEATURES", block), grep("^ORIGIN", block)-1)]
}
vars.features <- c("organism", "mol_type",
                   "chromosome", "map",
                   "gene", "gene_synonym", "note")
names(vars.features) <- vars.features
vars.features <- as.list(vars.features)
getF <- function(F, f) {
  line <- grep(sprintf('^ */%s=".*"$', f), F, value=TRUE)[1]
  gsub(sprintf('^ */%s="(.*)"$', f), "\\1", line)
}

mungeBlock <- function(block) {
  a <- vapply(vars.simple, function(v) getV(block, v), "")
  feat <- features(block)
  b <- vapply(vars.features, function(f) getF(feat, f), "")
  gid <- grep('^.*/db_xref="GeneID:.*"$', feat, value=TRUE)[1]
  b['GeneID'] <- gsub('^.*/db_xref="GeneID:(.*)"$', "\\1", gid)
  c(a, b)
}

gene_info <- as.data.frame(t(vapply(blocks, mungeBlock,
                                    c(unlist(vars.simple),
                                      unlist(vars.features),
                                      geneID=""))))

gene_info$ACCESSION.VERSION <- gsub("^(.*?) +.*$", "\\1", gene_info$VERSION)

save(gene_info, file=outputFileName)
