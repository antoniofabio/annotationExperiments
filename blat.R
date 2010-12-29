#! /usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)

usage <- function() {
  message("usage:")
  message("./blat.R databaseFile.rfa queryFile.fa outputFile.psl")
  message("

 databaseFile.rfa: reference database in fasta format
 queryFile.fa: query sequences in fasta format
 outputFile.psl: blat output filename (default: 'queryFile.psl')
")
}

cargs <- length(args)
if(cargs < 2 || cargs > 3) {
  message("wrong number of arguments (", cargs, ")\n")
  usage()
  quit(save="no", status=1)
}

rfaFile <- args[1]
faFile <- args[2]
if(cargs < 3) {
  pslFile <- gsub("^(.*)\\.fa$", "\\1.psl", faFile)
} else {
  pslFile <- args[3]
}

cmd <- sprintf("blat -noHead -minIdentity=100 -stepSize=7 %s %s %s",
               shQuote(rfaFile), shQuote(faFile), shQuote(pslFile))
message('executing shell command:')
message(shQuote(cmd))
system(cmd)
