#! /usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)

usage <- function() {
  message("usage:")
  message("./fastagrep.R input.fasta query > selection.fasta")
  message("

 input.fasta: sequences in fasta format
 query: regexp on which filter the input
 selection.fasta: the filtered sequences in fasta format
")
}

cargs <- length(args)
if(cargs != 2) {
  message("wrong number of arguments (", cargs, ")\n")
  usage()
  quit(save="no", status=1)
}
con <- file(args[1], open = "r")
query <- args[2]

rl <- function() readLines(con, n = 1, warn = FALSE)

while(length(line <- rl()) > 0) {
  if(grepl(query, line)) {
    cat(line, "\n", sep = "")
    cat(rl(), "\n", sep = "")
  }
}

close(con)
