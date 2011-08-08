#! /usr/bin/env Rscript
## convert Affy exon-style probesets fasta files to HG-style fasta files
args <- commandArgs(trailingOnly=TRUE)

con <- file(args[1], "r")

while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
  if(grepl("^>", line)) {
    line <- gsub("^(>.+):(.+:.+)$", "\\1|\\2", line)
  }
  writeLines(line)
}

close(con)
